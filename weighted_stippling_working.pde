import d3delaunayforprocessing.*;
PrintWriter output;

int pointAmount = 60000;

PVector[] points = new PVector[pointAmount];

double[] points2 = new double[pointAmount*2];

char letters[] = {

  ' ','.', '`', '¨', '~', ',', '-', '^', '³', '_', '²', ':', '!', '°', '/', ')', ';', '(', '±', '1', 'r', '+', '=', 'l',
  'i', '|', 't', '*', '?', '7', 'c', 'I', 'u', 'n', '2', 'z', 'C', '4', 'j', 'v', 'h', 'L', 'Y', 'k', 'o', 'a', 'Z',
  'J', '3', 'f', 'm', 'e', '5', 'A', 'G', '£', 'x', 'ƒ', 'V', 'T', 'F', 'O', 's', 'P', 'y', 'K', 'D', 'R', '0', '6',
  'U', '&', '9', 'w', 'S', 'B', '8', 'X', 'M', '¼', '½', '%', 'b', '$', 'd', 'E', 'g', 'H', 'p', 'q', 'N', 'W', 'Q', '¾'
  
}; //93 characters

int letterWeight[] = {

  0, 11, 11, 12, 14, 16, 16, 20, 21, 22, 22, 23, 23, 24, 25, 27, 28, 28, 28, 28, 30, 30, 30, 32, 32, 32, 33, 34, 36, 36,
  38, 38, 41, 41, 42, 42, 43, 43, 43, 43, 44, 45, 45, 45, 46, 46, 46, 46, 46, 46, 47, 47, 47, 48, 48, 48, 48, 49, 51,
  52, 52, 52, 53, 53, 53, 54, 54, 54, 54, 54, 55, 55, 55, 55, 56, 56, 56, 57, 58, 58, 58, 59, 59, 61, 61, 64, 64, 65,
  66, 66, 67, 68, 68, 72 

}; //93 characters

PImage img;


PFont brougham;

int itteration = 0;

void setup() {
  output = createWriter("writefile.txt");
  
  textSize(13);
  brougham = createFont("Brougham", 17);
  textFont(brougham);
  fill(0);
  img = loadImage("test.jpg");
  img.filter(GRAY);
  img.resize(1100, 1542);
  size(1100, 1542);
  
  for (int i = 0; i < pointAmount; i ++) {
    points[i] = new PVector();
    int x = int(random(img.width));
    int y = int(random(img.height));
    color c = img.get(x, y);
    if (random(250) > brightness(c)) {
      points[i].set(x, y);
    } else {
      i--;
    }
  }
  stroke(0);
  strokeWeight(0.5);
}

void draw() {

  for (int i = 0; i < pointAmount; i++) {

    points2[i*2] = points[i].x;
    points2[i*2+1] = points[i].y;
  }

  Delaunay d = new Delaunay(points2);
  Voronoi v = d.voronoi(new double[] {0, 0, width, height});
  
  background(255);
  //for (int i = 0;i < points2.length/2; i++){
  //  double[][] cells = v.cellPolygon(i);
  //   if (cells == null) continue;
  //  beginShape();
  //  strokeWeight(0.1);
  //  for (int j = 0; j < cells.length; j ++){
  //    vertex((float)cells[j][0],(float)cells[j][1]);
      
  //  }
  //  endShape();
  //}

  PVector[] centroid = new PVector[pointAmount];
  float[] weights = new float[pointAmount];
  float[] counts = new float[pointAmount];
  float[] avgWeights = new float[pointAmount];
  for (int i = 0; i < pointAmount; i++) {
    centroid[i] = new PVector();
  }

  img.loadPixels();
  int delaunayIndex = 0;
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      color c = get(i, j);
      float bright = brightness(c);
      float weight = bright / 255;
      delaunayIndex = d.find(i, j, delaunayIndex);
      centroid[delaunayIndex].x += i * weight;
      centroid[delaunayIndex].y += j * weight;
      weights[delaunayIndex] += weight;
      counts[delaunayIndex]++;
    }
  }

  float maxWeight = 0;
  for (int i = 0; i < centroid.length; i++) {
    if (weights[i] > 0) {
      centroid[i].div(weights[i]);
      avgWeights[i] = weights[i] / (counts[i]);
      if (avgWeights[i] > maxWeight) {
        maxWeight = avgWeights[i];
      }
    } else {
      centroid[i] = points[i].copy();
    }
  }



  for (int i = 0; i < points.length; i++) {
    points[i].lerp(centroid[i], 1);
  }
  
 char[] whichLetter = new char[pointAmount];

  for (int i = 0; i < points.length; i ++) {
    //println((int)points[i],(int)points[i+1]);
    color c = img.get((int(points[i].x)), (int(points[i].y)));
    float size = map(brightness(c), 0, 255, 72, 0);
    //println(size);
    //strokeWeight();
    
    int distance = Math.abs(letterWeight[0] - (int)size);
    int idx = 0;
    for (int t = 1; t < letterWeight.length; t++){
    
      int cdistance = Math.abs(letterWeight[t] - (int)size);
      if(cdistance < distance){
        idx = t;
        distance = cdistance;
    }
     whichLetter[i] = letters[idx];
     //println(whichLetter);
      
    }
    
    textSize(17);
    text(whichLetter[i],(int)points[i].x, (int)points[i].y);
    //strokeWeight(size);
    //point((int)points[i].x, (int)points[i].y);
    output.println("<"+(int)points[i].x+";"+(int)((points[i].y)*1.6)+";"+whichLetter[i]+">");
    stroke(0);
  }

  itteration++;
  
  if (itteration == 40) {
    output.flush();  // Writes the remaining data to the file
    output.close();  // Finishes the file
    save("export.jpg");
    exit();  // Stops the program
    
  }

}
