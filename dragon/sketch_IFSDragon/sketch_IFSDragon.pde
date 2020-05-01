float xn1, yn1; //now point
float xn2, yn2; //next point

float a,b,c,d,e,f; //coefficient

float p; //variable

void setup(){
  size(600,600);
  background(0);
  stroke(255);
  fill(255);
  xn1 = 0;
  yn1 = 0;
}

void draw(){
  p = random(1);
  if(p < 0.8){  //set1 80%
    a = 0.824074;
    b = 0.281428;
    c = -0.212346;
    d = 0.864198;
    e = -1.882290;
    f = -0.110607;
  }else{ //set2 20%
    a = 0.088272;
    b = 0.520988;
    c = -0.463889;
    d = -0.377778;
    e = 0.785360;
    f = 8.095795;
  }
  translate(width/2, height/2 + height/4);
  
  
  //next point
  xn2 = a * xn1 + b * yn1 + e;
  yn2 = c * xn1 + d * yn1 + f;
  
  ellipse(-xn2 * 40, -yn2 * 40, 3 ,3);
  
  xn1 = xn2;
  yn1 = yn2;
}
  
