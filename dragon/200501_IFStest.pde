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
  if(p < 0.01){  //set1 1%
    a = 0;
    b = 0;
    c = 0;
    d = 0.16;
    e = 0;
    f = 0;
  }else if(p >= 0.01 && p < 0.08){ //set2 7%
    a = 0.2;
    b = -0.26;
    c = 0.23;
    d = 0.22;
    e = 0;
    f = 1.6;
   }else if(p >= 0.08 && p < 0.15){ //set3 7%
    a = -0.15;
    b = 0.28;
    c = 0.26;
    d = 0.24;
    e = 0;
    f = 0.44;
   }else{ //set4 85%
    a = 0.85;
    b = 0.04;
    c = -0.04;
    d = 0.85;
    e = 0;
    f = 1.6;
  }
  translate(width/2, height/2 + height/4);
  
  
  //next point
  xn2 = a * xn1 + b * yn1 + e;
  yn2 = c * xn1 + d * yn1 + f;
  
  ellipse(-xn2 * 40, -yn2 * 40, 3 ,3);
  
  xn1 = xn2;
  yn1 = yn2;
}
  
