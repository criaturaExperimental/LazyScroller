// Imports

import gab.opencv.*;
import processing.video.*;

import java.awt.*;
import java.awt.event.*;

// Tweaks
int mouse_speed = 10;
int up_delay = 1800;
int down_delay = 2000;

Robot robot;
PFont pfont;

Capture video;
OpenCV opencv;
ArrayList<Contour> contours;

//Face detection constants
float DETECT_SCALE = 1.2;
int DETECT_MINNEIGHBOURS = 7;
int DETECT_MINSIZE = 0;
int DETECT_MAXSIZE = 0;

Rectangle[] faces;

boolean stopme = false;

//Workaround for delay
long lastTime = 0;

//Radius
int rstop = 40;
int rup = 40;

void setup() {

  size(480, 360);
  stroke(255, 255, 255);
  strokeWeight(5);
  noFill();

  opencv = new OpenCV(this, 640, 480);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  textSize(32);

  lastTime = millis();

  video = new Capture(this, 640, 480);
  video.start();

  try {
    robot = new Robot();
    robot.setAutoDelay(0);
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}

void draw() {

  if (video.available() == true) {
    video.read();
  }
  image(video, 0, 0, 480, 360);

  opencv.loadImage(video);
  opencv.useColor(HSB);

  faces = opencv.detect(DETECT_SCALE, DETECT_MINNEIGHBOURS, 0, DETECT_MINSIZE, DETECT_MAXSIZE);

  ellipse(400, 200, rup, rup);
  ellipse(80, 200, rstop, rstop);

  scale(0.75);

  opencv.setGray(opencv.getH());

  opencv.inRange(18, 22);
  contours = opencv.findContours(true, true);


  for (int i = 0; i < faces.length; i++) {
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);

    if(stopme == false){
      scroll_down();
    }

    for (int f=0; f<contours.size(); f++) {
      if (contours.get(f).area() > 28000) {
        //contours.get(f).draw();
        stopme = false;
      }
      if (contours.get(f).containsPoint(int(400/0.75), int(200/0.75))) {
        println("up");
        rup = (frameCount*5 % 100) * (100 - (frameCount*5 % 100)) / 50;
        stopme = true;
        scroll_up();
      }
      if (contours.get(f).containsPoint(int(80/0.75), int(200/0.75)) ||
          contours.get(f).containsPoint(int(85/0.75), int(200/0.75)) ||
          contours.get(f).containsPoint(int(75/0.75), int(200/0.75)) ||
          contours.get(f).containsPoint(int(80/0.75), int(195/0.75)) ||
          contours.get(f).containsPoint(int(85/0.75), int(195/0.75)) ||
          contours.get(f).containsPoint(int(75/0.75), int(195/0.75))) {
        halt();
        stopme = true;
      }
    }
  }

}

void scroll_down(){
  if ( millis() - lastTime > down_delay ) {
    robot.mouseWheel(mouse_speed);
    println("down");
    lastTime = millis();
  }
}

void scroll_up(){
  text("Going up", 10, 30);
  if ( millis() - lastTime > down_delay ) {
    robot.mouseWheel(-mouse_speed);
    println("up");
    lastTime = millis();
  }
}

void halt(){
    println("stop ");
    stopme = true;
    text("Halt!", 10, 30);
}
