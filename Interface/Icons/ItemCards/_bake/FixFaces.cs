using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
class FixFaces {
  static void Rgb565(int r,int g,int b,out ushort c){c=(ushort)(((r>>3)<<11)|((g>>2)<<5)|(b>>3));}
  static void Enc(byte[] rgba,int stride,int bx,int by,byte[] dst,int di){
    int aMin=255,aMax=0; for(int py=0;py<4;py++)for(int px=0;px<4;px++){int a=rgba[((by+py)*stride+(bx+px))*4+3]; if(a<aMin)aMin=a; if(a>aMax)aMax=a;}
    dst[di]=(byte)aMax; dst[di+1]=(byte)aMin; ulong ab=0;
    for(int i=0;i<16;i++){int a=rgba[((by+(i>>2))*stride+(bx+(i&3)))*4+3]; int idx=0; if(aMax!=aMin){int t=(a-aMin)*7/Math.Max(1,aMax-aMin); int[] o={0,2,3,4,5,6,7,1}; idx=o[Math.Max(0,Math.Min(7,7-t))];} ab|=((ulong)idx)<<(3*i);}
    for(int i=0;i<6;i++) dst[di+2+i]=(byte)((ab>>(8*i))&0xFF);
    int c0r=0,c0g=0,c0b=0,c1r=255,c1g=255,c1b=255,bm=-1,bn=9999; int[,] cols=new int[16,3];
    for(int i=0;i<16;i++){int o=((by+(i>>2))*stride+(bx+(i&3)))*4; int r=rgba[o],g=rgba[o+1],b=rgba[o+2]; cols[i,0]=r;cols[i,1]=g;cols[i,2]=b; int y=r*2+g*3+b; if(y>bm){bm=y;c0r=r;c0g=g;c0b=b;} if(y<bn){bn=y;c1r=r;c1g=g;c1b=b;}}
    ushort c0,c1; Rgb565(c0r,c0g,c0b,out c0); Rgb565(c1r,c1g,c1b,out c1); if(c0<c1){var t=c0;c0=c1;c1=t; int tr=c0r;c0r=c1r;c1r=tr; tr=c0g;c0g=c1g;c1g=tr; tr=c0b;c0b=c1b;c1b=tr;}
    dst[di+8]=(byte)(c0&0xFF); dst[di+9]=(byte)(c0>>8); dst[di+10]=(byte)(c1&0xFF); dst[di+11]=(byte)(c1>>8);
    int[] pr={c0r,c1r,(2*c0r+c1r)/3,(c0r+2*c1r)/3}; int[] pg={c0g,c1g,(2*c0g+c1g)/3,(c0g+2*c1g)/3}; int[] pb={c0b,c1b,(2*c0b+c1b)/3,(c0b+2*c1b)/3};
    uint bits=0; for(int i=0;i<16;i++){int best=0,bd=1<<30; for(int k=0;k<4;k++){int dr=cols[i,0]-pr[k],dg=cols[i,1]-pg[k],db=cols[i,2]-pb[k]; int d=dr*dr+dg*dg+db*db; if(d<bd){bd=d;best=k;}} bits|=(uint)(best<<(2*i));}
    BitConverter.GetBytes(bits).CopyTo(dst,di+12);
  }
  static void SaveBlp(Bitmap bmp,string path){
    int w=bmp.Width,h=bmp.Height; var data=new byte[w*h*4]; var bd=bmp.LockBits(new Rectangle(0,0,w,h),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb); Marshal.Copy(bd.Scan0,data,0,data.Length); bmp.UnlockBits(bd);
    for(int i=0;i<data.Length;i+=4){byte t=data[i]; data[i]=data[i+2]; data[i+2]=t;}
    var dxt=new byte[(w/4)*(h/4)*16]; int di=0; for(int by=0;by<h;by+=4)for(int bx=0;bx<w;bx+=4){Enc(data,w,bx,by,dxt,di); di+=16;}
    using(var fs=new FileStream(path,FileMode.Create,FileAccess.Write)) using(var bw=new BinaryWriter(fs)){
      bw.Write(new byte[]{(byte)'B',(byte)'L',(byte)'P',(byte)'2'}); bw.Write((uint)1); bw.Write((byte)2); bw.Write((byte)8); bw.Write((byte)7); bw.Write((byte)1); bw.Write((uint)w); bw.Write((uint)h);
      for(int i=0;i<16;i++) bw.Write(i==0?148u:0u); for(int i=0;i<16;i++) bw.Write(i==0?(uint)dxt.Length:0u); bw.Write(dxt);
    }
  }
  static Bitmap Grey(Bitmap src){
    var dst=new Bitmap(src.Width,src.Height,PixelFormat.Format32bppArgb);
    for(int y=0;y<src.Height;y++) for(int x=0;x<src.Width;x++){ var p=src.GetPixel(x,y); int g=(int)(0.3*p.R+0.59*p.G+0.11*p.B); g=(int)(g*0.55); dst.SetPixel(x,y,Color.FromArgb(p.A,g,g,g)); }
    return dst;
  }
  static void Main(){
    string root=@"E:\wowdecomp\wowdecomp\Interface\Icons\ItemCards";
    for(int i=1;i<=8;i++){
      using(var face=(Bitmap)Image.FromFile(Path.Combine(root,"Color","face_"+i+".png"))){
        // color face only
        face.Save(Path.Combine(root,"Color",i+".png"), ImageFormat.Png);
        SaveBlp(face, Path.Combine(root,"Color",i+".blp"));
        using(var dark=Grey(face)){
          // add subtle lock mark
          using(var g=Graphics.FromImage(dark)){
            g.SmoothingMode=SmoothingMode.AntiAlias;
            using(var pen=new Pen(Color.FromArgb(180,160,160,160),6)){
              g.DrawEllipse(pen, 98, 90, 60, 60);
              g.FillRectangle(new SolidBrush(Color.FromArgb(200,150,150,150)), 110, 118, 36, 40);
            }
          }
          dark.Save(Path.Combine(root,"Dark",i+".png"), ImageFormat.Png);
          SaveBlp(dark, Path.Combine(root,"Dark",i+".blp"));
        }
        Console.WriteLine("fixed "+i);
      }
    }
    Console.WriteLine("OK");
  }
}
