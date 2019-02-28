class ParticleSystem {
  ArrayList<particle> particles;
  float dragfac;

  ParticleSystem() {
    particles = new ArrayList<particle>();
    dragfac = 0.005;
  }

  void addParticleSystem(int num, float dir, PVector origin, boolean radial) {
    for (int i = 0; i<num; i++) {
      particle p;
      float angle = 0;
      PVector posOffset = new PVector(random(-10, 10), random(-FFTdify/2, FFTdify/2));
      if (radial) {
        angle = random(0, TWO_PI);
        PVector tmpDir = PVector.fromAngle(angle);
        tmpDir.setMag(random(0, 20));
        posOffset = tmpDir;
      }
      p = new particle(origin.copy().add(posOffset), angle, dir);
      addParticle(p);
    }
  }

  void addParticle(particle p) {
    particles.add(p);
  }

  ArrayList<particle> getParticlesAtRange(PVector posIn, float range, int thres) {
    ArrayList<particle> parts = new ArrayList<particle>();
    for (particle p : particles) {
      float dist = dist(p.pos.x, p.pos.y, posIn.x, posIn.y);
      if (dist > range-thres && dist < range+thres) {
        parts.add(p);
      }
    }
    return parts;
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}


class particle {

  PVector pos;
  PVector ppos;
  PVector vel;
  PVector acc;

  int lifespan;

  PVector drag;

  boolean hitByShockwave;

  particle(PVector p, float a, float d) {
    pos = p.copy();
    //vel = new PVector(d*3, random(-0.05, 0.05)+moveDir);
    float angle = a+random(-0.05, 0.05);
    vel = PVector.fromAngle(angle);
    vel.setMag(d*1.8+d*random(0,1.5));
    acc = new PVector(0, 0);

    hitByShockwave = false;

    ppos = pos.copy();
    lifespan = int(random(200, 500)*int(random(1.0, 2.01)));
  }

  void run() {
    update();
    display();
  }

  void display() {
    //stroke(abs(vel.x*255),0,abs(vel.y*255),40);
    //point(pos.x, pos.y);
    float bandValue = heightToFTTVal(pos.y-FFTdify/2);
    float bonusFlash = 0;
    if (hitByShockwave) {
      bonusFlash = 0.3;
    }
    float flashFac = constrain((bandValue/80) + bonusFlash, 0.4, 2);
    float r = abs(vel.x)*100+flashFac*40;
    float g = 255-abs(vel.x)*60+flashFac*60;
    float b = abs(vel.y)*400+flashFac*80;
    float a = constrain(lifespan*flashFac, 0, 255);
    stroke(r, g, b, a);
    line(pos.x, pos.y, ppos.x, ppos.y);
  }

  void updatePpos() {
    ppos = pos.copy();
  }

  void update() {
    lifespan -= 2;
    updatePpos();

    drag = vel.copy();
    drag.setMag(particleSystem.dragfac*vel.mag());

    float angle = noise(pos.x/4, pos.y/4, t) * TWO_PI * 4;
    PVector noiseVec = PVector.fromAngle(angle);
    noiseVec.setMag(0.03); 
    acc.add(noiseVec);

    vel.add(acc);
    vel.sub(drag);
    pos.add(vel.copy().mult(1+globalMoveSpeedMod));

    acc = new PVector(0, 0);
  }

  void applyForce(PVector f) {
    acc.add(f);
  }

  boolean isDead() {
    return (lifespan < 0);
  }
}
