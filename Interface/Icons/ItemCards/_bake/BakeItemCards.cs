using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;

internal static class BakeItemCards
{
    private static void Rgb565(int r, int g, int b, out ushort c)
    {
        c = (ushort)(((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3));
    }

    private static void EncodeDxt5Block(byte[] rgba, int stride, int bx, int by, byte[] dst, int di)
    {
        int aMin = 255, aMax = 0;
        for (int py = 0; py < 4; py++)
        {
            for (int px = 0; px < 4; px++)
            {
                int a = rgba[((by + py) * stride + (bx + px)) * 4 + 3];
                if (a < aMin) aMin = a;
                if (a > aMax) aMax = a;
            }
        }

        dst[di] = (byte)aMax;
        dst[di + 1] = (byte)aMin;
        ulong abits = 0;
        for (int i = 0; i < 16; i++)
        {
            int px = i & 3, py = i >> 2;
            int a = rgba[((by + py) * stride + (bx + px)) * 4 + 3];
            int idx = 0;
            if (aMax != aMin)
            {
                int t = (a - aMin) * 7 / Math.Max(1, aMax - aMin);
                int[] order = { 0, 2, 3, 4, 5, 6, 7, 1 };
                idx = order[Math.Max(0, Math.Min(7, 7 - t))];
            }
            abits |= ((ulong)idx) << (3 * i);
        }
        for (int i = 0; i < 6; i++)
            dst[di + 2 + i] = (byte)((abits >> (8 * i)) & 0xFF);

        int c0r = 0, c0g = 0, c0b = 0, c1r = 255, c1g = 255, c1b = 255, bestMax = -1, bestMin = 9999;
        int[,] cols = new int[16, 3];
        for (int i = 0; i < 16; i++)
        {
            int px = i & 3, py = i >> 2, o = ((by + py) * stride + (bx + px)) * 4;
            int r = rgba[o], g = rgba[o + 1], b = rgba[o + 2];
            cols[i, 0] = r; cols[i, 1] = g; cols[i, 2] = b;
            int y = r * 2 + g * 3 + b;
            if (y > bestMax) { bestMax = y; c0r = r; c0g = g; c0b = b; }
            if (y < bestMin) { bestMin = y; c1r = r; c1g = g; c1b = b; }
        }

        ushort c0, c1;
        Rgb565(c0r, c0g, c0b, out c0);
        Rgb565(c1r, c1g, c1b, out c1);
        if (c0 < c1)
        {
            var t = c0; c0 = c1; c1 = t;
            int tr = c0r; c0r = c1r; c1r = tr;
            tr = c0g; c0g = c1g; c1g = tr;
            tr = c0b; c0b = c1b; c1b = tr;
        }

        dst[di + 8] = (byte)(c0 & 0xFF); dst[di + 9] = (byte)(c0 >> 8);
        dst[di + 10] = (byte)(c1 & 0xFF); dst[di + 11] = (byte)(c1 >> 8);

        int[] pr = { c0r, c1r, (2 * c0r + c1r) / 3, (c0r + 2 * c1r) / 3 };
        int[] pg = { c0g, c1g, (2 * c0g + c1g) / 3, (c0g + 2 * c1g) / 3 };
        int[] pb = { c0b, c1b, (2 * c0b + c1b) / 3, (c0b + 2 * c1b) / 3 };
        uint bits = 0;
        for (int i = 0; i < 16; i++)
        {
            int best = 0, bd = 1 << 30;
            for (int k = 0; k < 4; k++)
            {
                int dr = cols[i, 0] - pr[k], dg = cols[i, 1] - pg[k], db = cols[i, 2] - pb[k];
                int d = dr * dr + dg * dg + db * db;
                if (d < bd) { bd = d; best = k; }
            }
            bits |= (uint)(best << (2 * i));
        }
        BitConverter.GetBytes(bits).CopyTo(dst, di + 12);
    }

    public static void SaveBlp2Dxt5(Bitmap bmp, string path)
    {
        int w = bmp.Width, h = bmp.Height;
        if ((w % 4) != 0 || (h % 4) != 0)
            throw new Exception("size must be multiple of 4: " + w + "x" + h);

        var data = new byte[w * h * 4];
        var bd = bmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
        Marshal.Copy(bd.Scan0, data, 0, data.Length);
        bmp.UnlockBits(bd);
        for (int i = 0; i < data.Length; i += 4)
        {
            byte t = data[i];
            data[i] = data[i + 2];
            data[i + 2] = t;
        }

        int blocks = (w / 4) * (h / 4);
        var dxt = new byte[blocks * 16];
        int di = 0;
        for (int by = 0; by < h; by += 4)
            for (int bx = 0; bx < w; bx += 4)
            {
                EncodeDxt5Block(data, w, bx, by, dxt, di);
                di += 16;
            }

        using (var fs = new FileStream(path, FileMode.Create, FileAccess.Write))
        using (var bw = new BinaryWriter(fs))
        {
            bw.Write(new byte[] { (byte)'B', (byte)'L', (byte)'P', (byte)'2' });
            bw.Write((uint)1);
            bw.Write((byte)2);
            bw.Write((byte)8);
            bw.Write((byte)7);
            bw.Write((byte)1);
            bw.Write((uint)w);
            bw.Write((uint)h);
            uint off0 = 148;
            for (int i = 0; i < 16; i++) bw.Write(i == 0 ? off0 : 0u);
            for (int i = 0; i < 16; i++) bw.Write(i == 0 ? (uint)dxt.Length : 0u);
            bw.Write(dxt);
        }
    }

    private static Bitmap Resize(Bitmap src, int w, int h)
    {
        var dst = new Bitmap(w, h, PixelFormat.Format32bppArgb);
        using (var g = Graphics.FromImage(dst))
        {
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.Clear(Color.Transparent);
            g.DrawImage(src, 0, 0, w, h);
        }
        return dst;
    }

    private static Bitmap ComposeCard(Bitmap face, Bitmap frame, bool grey)
    {
        var canvas = new Bitmap(256, 256, PixelFormat.Format32bppArgb);
        using (var g = Graphics.FromImage(canvas))
        {
            g.Clear(Color.FromArgb(255, 12, 12, 14));
            var faceRect = new Rectangle(28, 22, 200, 212);
            if (grey)
            {
                using (var attr = new ImageAttributes())
                {
                    var cm = new ColorMatrix(new float[][]
                    {
                        new float[]{0.3f,0.3f,0.3f,0,0},
                        new float[]{0.3f,0.3f,0.3f,0,0},
                        new float[]{0.3f,0.3f,0.3f,0,0},
                        new float[]{0,0,0,1,0},
                        new float[]{0,0,0,0,1}
                    });
                    attr.SetColorMatrix(cm);
                    g.DrawImage(face, faceRect, 0, 0, face.Width, face.Height, GraphicsUnit.Pixel, attr);
                }
            }
            else
            {
                g.DrawImage(face, faceRect);
            }
            g.DrawImage(frame, new Rectangle(0, 0, 256, 256));
        }
        return canvas;
    }

    private static void EnsureDir(string path)
    {
        Directory.CreateDirectory(path);
    }

    public static int Main(string[] args)
    {
        string root = args.Length > 0 ? args[0] : @"E:\wowdecomp\wowdecomp\Interface\Icons\ItemCards";
        string sheetPath = args.Length > 1 ? args[1] : @"C:\Users\Administrator\.cursor\projects\e-wowdecomp\assets\itemcard_faces_sheet_2x4.jpg";
        string framesDir = args.Length > 2 ? args[2] : @"E:\wowdecomp\wowdecomp\Interface\NativeUI\BundledAddOns\____Function\ItemCardsAssets\frames";
        string bgPath = args.Length > 3 ? args[3] : @"C:\Users\Administrator\.cursor\projects\e-wowdecomp\assets\itemcards_bg_1024.jpg";
        string btnPath = args.Length > 4 ? args[4] : @"C:\Users\Administrator\.cursor\projects\e-wowdecomp\assets\itemcard_btn_upgrade.jpg";

        EnsureDir(Path.Combine(root, "Dark"));
        EnsureDir(Path.Combine(root, "Color"));
        EnsureDir(Path.Combine(root, "Frame"));
        EnsureDir(Path.Combine(root, "UI"));

        using (var sheet = (Bitmap)Image.FromFile(sheetPath))
        {
            int cw = sheet.Width / 4;
            int ch = sheet.Height / 2;
            var faces = new Bitmap[8];
            for (int r = 0; r < 2; r++)
            {
                for (int c = 0; c < 4; c++)
                {
                    int i = r * 4 + c;
                    var rect = new Rectangle(c * cw, r * ch, cw, ch);
                    using (var face = sheet.Clone(rect, sheet.PixelFormat))
                    {
                        faces[i] = Resize(face, 256, 256);
                        faces[i].Save(Path.Combine(root, "Color", "face_" + (i + 1) + ".png"), ImageFormat.Png);
                        Console.WriteLine("face " + (i + 1));
                    }
                }
            }

            using (var frame1 = Resize((Bitmap)Image.FromFile(Path.Combine(framesDir, "level_01.png")), 256, 256))
            {
                for (int i = 0; i < 8; i++)
                {
                    using (var dark = ComposeCard(faces[i], frame1, true))
                    {
                        string n = (i + 1).ToString();
                        dark.Save(Path.Combine(root, "Dark", n + ".png"), ImageFormat.Png);
                        SaveBlp2Dxt5(dark, Path.Combine(root, "Dark", n + ".blp"));
                        Console.WriteLine("dark " + n);
                    }
                    using (var color = ComposeCard(faces[i], frame1, false))
                    {
                        string n = (i + 1).ToString();
                        color.Save(Path.Combine(root, "Color", n + ".png"), ImageFormat.Png);
                        SaveBlp2Dxt5(color, Path.Combine(root, "Color", n + ".blp"));
                        Console.WriteLine("color " + n);
                    }
                }
            }

            for (int i = 0; i < 8; i++)
                faces[i].Dispose();
        }

        // Bake level frames 1-10 to Frame folder for overlay usage
        for (int lv = 1; lv <= 10; lv++)
        {
            string src = Path.Combine(framesDir, "level_" + lv.ToString("00") + ".png");
            using (var fr = Resize((Bitmap)Image.FromFile(src), 256, 256))
            {
                fr.Save(Path.Combine(root, "Frame", "level_" + lv + ".png"), ImageFormat.Png);
                SaveBlp2Dxt5(fr, Path.Combine(root, "Frame", "level_" + lv + ".blp"));
                Console.WriteLine("frame " + lv);
            }
        }

        using (var bg = Resize((Bitmap)Image.FromFile(bgPath), 1024, 1024))
        {
            bg.Save(Path.Combine(root, "UI", "panel_bg.png"), ImageFormat.Png);
            SaveBlp2Dxt5(bg, Path.Combine(root, "UI", "panel_bg.blp"));
            Console.WriteLine("panel_bg");
        }

        using (var btn = Resize((Bitmap)Image.FromFile(btnPath), 256, 128))
        {
            btn.Save(Path.Combine(root, "UI", "btn_upgrade.png"), ImageFormat.Png);
            SaveBlp2Dxt5(btn, Path.Combine(root, "UI", "btn_upgrade.blp"));
            Console.WriteLine("btn_upgrade");
        }

        Console.WriteLine("BAKE_OK");
        return 0;
    }
}
