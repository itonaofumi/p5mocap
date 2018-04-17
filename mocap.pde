import SimpleOpenNI.*;

SimpleOpenNI  context;

PrintWriter output;

boolean isWriteFile = false;

color[] userClr = new color[] {
  color(255, 0, 0),
  color(0, 255, 0),
  color(0, 0, 255),
  color(255, 255, 0),
  color(255, 0, 255),
  color(0, 255, 255)
};

void setup() {
  size(640, 480);
  
  context = new SimpleOpenNI(this);
  if (context.isInit() == false) {
     println("Can't init SimpleOpenNI, maybe the camera is not connected.");
     exit();
     return;
  }
  
  // enable depthMap generation
  context.enableDepth();
   
  // enable skeleton generation for all joints
  context.enableUser();

  output = createWriter("positions.txt");
}

void draw() {
  // update camera
  context.update();
  
  // draw depthImage
  image(context.userImage(), 0, 0);
  
  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for (int i = 0; i < userList.length; i++) {
    if (context.isTrackingSkeleton(userList[i])) {
      stroke(userClr[(userList[i] - 1) % userClr.length]);
      drawSkeleton(userList[i]);
      drawJointPos(userList[i]);
    }      
     
    // draw the center of mass
    PVector com = new PVector();
    if (context.getCoM(userList[i], com)) drawCenterOfMass(userList[i], com);
  }

  // control write file
  if (keyPressed == true) {
    isWriteFile = !isWriteFile;
  }
}

void drawSkeleton(int userId) {
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
}

void drawCenterOfMass(int userId, PVector com) {
  PVector com2d = new PVector();
  context.convertRealWorldToProjective(com, com2d);
  stroke(100, 255, 0);
  strokeWeight(1);
  beginShape(LINES);
    vertex(com2d.x, com2d.y - 5);
    vertex(com2d.x, com2d.y + 5);

    vertex(com2d.x - 5, com2d.y);
    vertex(com2d.x + 5, com2d.y);
  endShape();
  
  fill(0,255,100);
  text(Integer.toString(userId), com2d.x, com2d.y);
}

void drawJointPos(int userId) {
  PVector[] jointPos = {
      new PVector(), new PVector(), new PVector(), new PVector(), new PVector(),
      new PVector(), new PVector(), new PVector(), new PVector(), new PVector(),
      new PVector(), new PVector(), new PVector(), new PVector(), new PVector()
  };
        
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, jointPos[0]);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_NECK, jointPos[1]);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_TORSO, jointPos[2]);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, jointPos[3]);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, jointPos[4]);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, jointPos[5]);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, jointPos[6]);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, jointPos[7]);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, jointPos[8]);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HIP, jointPos[9]);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_KNEE, jointPos[10]);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_FOOT, jointPos[11]);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HIP, jointPos[12]);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, jointPos[13]);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, jointPos[14]);
    
  String s = new String();
  for (int i = 0; i < jointPos.length; i++) {
    // draw joint for projection position.
    PVector projectionPos = new PVector();
    context.convertRealWorldToProjective(jointPos[i], projectionPos);
    ellipse(projectionPos.x, projectionPos.y, 25, 25);

    // write the skeleton position to file
    if (i == jointPos.length -1) {
      s += jointPos[i];
      if (isWriteFile) output.println(s);
    } else {
      s += jointPos[i] + ",";
    }
  }
}

//------------------------------------------------------------------------------
// SimpleOpenNI events
//------------------------------------------------------------------------------
void onNewUser(SimpleOpenNI curContext, int userId) {
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId) {
  //println("onVisibleUser - userId: " + userId);
}

void keyPressed() {
  switch(key) {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }
}
