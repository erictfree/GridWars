/*
 * GridWars
 * Copyright (c) 2026 Eric Freeman, PhD
 * University of Texas at Austin
 * April 7, 2026
 *
 * MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

class SmartBot extends Bot {
int[] A=new int[90000],B=new int[90000],C=new int[90000];boolean[] V=new boolean[90000];
int u=1,v=0,j=-1,k=-1,q=0,L=0,S=0,T=0;float E=1.0;
SmartBot(int x,int y,color c,String n){super(x,y,c,n);}
Direction getNextMove(GameInfo g){int w=g.cols,h=g.rows;float p=g.getProgress();q=(x==j&&y==k)?q+1:0;j=x;k=y;S++;int z=score-L;T+=z>0?z:0;L=score;if(S>=20){E=(float)T/S;S=0;T=0;}ArrayList<Direction>f=getFreeDirs();if(f.size()>0){if(p>0.6){Direction b1=null;float s1=-999;for(Direction d1:f){int a1=x+d1.dx,e1=y+d1.dy,r1=0,i1=a1,o1=e1;while(r1<15&&g.inBounds(o1,i1)&&g.isUnclaimed(o1,i1)){r1++;i1+=d1.dx;o1+=d1.dy;}int p1=max(0,e1-10),q1=max(0,a1-10),p2=min(h-1,e1+10),q2=min(w-1,a1+10);if(d1.dx>0)q1=a1;if(d1.dx<0)q2=a1;if(d1.dy>0)p1=e1;if(d1.dy<0)p2=e1;float m1=r1*8+g.countUnclaimedInRegion(p1,q1,p2,q2)*2;for(Direction n1:DIRS)if(g.isUnclaimed(e1+n1.dy,a1+n1.dx))m1+=4;Bot t1=g.getNearestBot(a1,e1,id);if(t1!=null&&abs(t1.x-a1)+abs(t1.y-e1)<3)m1-=20;if(q>3)m1+=random(8);if(m1>s1){s1=m1;b1=d1;}}if(b1!=null){u=b1.dx;v=b1.dy;}return b1!=null?b1:f.get(0);}Direction m2=Z(u,v);if(m2!=null&&canClaim(m2))return m2;if(u!=0){Direction s2=Z(0,1);if(s2!=null&&canClaim(s2)){u=-u;return s2;}s2=Z(0,-1);if(s2!=null&&canClaim(s2)){u=-u;return s2;}}else{Direction s3=Z(1,0);if(s3!=null&&canClaim(s3)){v=-v;return s3;}s3=Z(-1,0);if(s3!=null&&canClaim(s3)){v=-v;return s3;}}Direction b2=null;float s4=-999;for(Direction d2:f){int r2=0,i2=x+d2.dx,o2=y+d2.dy;while(r2<20&&g.inBounds(o2,i2)&&g.isUnclaimed(o2,i2)){r2++;i2+=d2.dx;o2+=d2.dy;}int a2=x+d2.dx,e2=y+d2.dy,c2=0;for(Direction n2:DIRS)if(g.isUnclaimed(e2+n2.dy,a2+n2.dx))c2++;float m3=r2*10+c2*3;Bot t2=g.getNearestBot(x,y,id);if(t2!=null){float D2=abs(t2.x-x)+abs(t2.y-y);if(D2<15)m3+=(abs(t2.x-a2)+abs(t2.y-e2)-D2)*5;}if(q>3)m3+=random(10);if(m3>s4){s4=m3;b2=d2;}}if(b2!=null){u=b2.dx;v=b2.dy;}return b2!=null?b2:f.get(0);}int t3=w*h,l3=min(t3,90000);java.util.Arrays.fill(V,0,l3,false);int H=0,F=0;int I=y*w+x;if(I>=0&&I<l3)V[I]=true;boolean G=p>0.6;int X=G?8:0;for(int i3=0;i3<DIRS.length;i3++){int a3=x+DIRS[i3].dx,e3=y+DIRS[i3].dy;if(!g.inBounds(e3,a3))continue;int c3=e3*w+a3;if(c3<0||c3>=l3||V[c3])continue;V[c3]=true;if(g.isUnclaimed(e3,a3))return DIRS[i3];if(F<90000){A[F]=a3;B[F]=e3;C[F]=i3;F++;}}int W=F,D=1,R=-1;float s5=-999;int P=-1;while(H<F&&H<89996){if(H>=W){D++;W=F;if(R>=0&&D>R+X)break;}int a4=A[H],e4=B[H],c4=C[H];H++;for(int i4=0;i4<DIRS.length;i4++){int n4=a4+DIRS[i4].dx,o4=e4+DIRS[i4].dy;if(!g.inBounds(o4,n4))continue;int d4=o4*w+n4;if(d4<0||d4>=l3||V[d4])continue;V[d4]=true;if(g.isUnclaimed(o4,n4)){if(R<0)R=D;int K=g.countUnclaimedInRegion(max(0,o4-10),max(0,n4-10),min(h-1,o4+10),min(w-1,n4+10));float m4;if(!G){m4=(float)K/max(1,D);Bot b3=g.getNearestBot(n4,o4,id);if(b3!=null&&abs(b3.x-n4)+abs(b3.y-o4)<10)m4*=0.3;}else{int J=g.countUnclaimedInRegion(max(0,o4-20),max(0,n4-20),min(h-1,o4+20),min(w-1,n4+20));float Y=K+(float)(J-K)/3.0;Bot b4=g.getNearestBot(n4,o4,id);if(b4!=null){float O=abs(b4.x-n4)+abs(b4.y-o4);if(O<D)Y*=0.15;else if(O<D+3)Y*=0.5;}m4=Y/max(1,E<0.3?sqrt(D):(float)D);}if(m4>s5){s5=m4;P=c4;}continue;}if(F<90000){A[F]=n4;B[F]=o4;C[F]=c4;F++;}}}if(P>=0){Direction c5=DIRS[P];u=c5.dx;v=c5.dy;return c5;}return randomDir();}
Direction Z(int a,int b){for(Direction d:DIRS)if(d.dx==a&&d.dy==b)return d;return null;}
}