class ShockwaveSystem {
  ArrayList<shockwave> shockwaves;

  ShockwaveSystem() {
    shockwaves = new ArrayList<shockwave>();
  }

  void addShockwave(shockwave p) {
    shockwaves.add(p);
  }

  void run() {
    for (int i = shockwaves.size()-1; i >= 0; i--) {
      shockwave p = shockwaves.get(i);
      p.run();
      if (p.isDead()) {
        shockwaves.remove(i);
      }
    }
  }
}


class shockwave {

  PVector pos;

  int lifetime;
  int lifespan;

  int speed;

  float curRad;

  float strength;

  boolean pullIn;

  shockwave(PVector p, int sp, int dur, float sB, boolean pI) {
    pos = p.copy();
    speed = sp;
    lifespan = dur;
    pullIn = pI;

    lifetime = lifespan;
    curRad = 0;
    strength = 1+sB;
  }

  void run() {
    update();
    //display();
    //coolDisplay();
  }

  void display() {
    noFill();
    stroke(255, 0, 0, map(lifetime, lifespan, 0, 250, 0));
    ellipseMode(CENTER);
    ellipse(pos.x, pos.y, curRad, curRad);
  }

  void update() {
    lifetime--;
    curRad = (lifespan-lifetime)*speed;
    applyForceToParticles();
  }

  void applyForceToParticles() {
    ArrayList<particle> parts = new ArrayList<particle>();

    parts = particleSystem.getParticlesAtRange(pos, curRad/2, speed/2);

    float curMag = map(lifetime, lifespan, 0, strength, 0);
    for (particle p : parts) {
      if (!p.hitByShockwave) {
        p.hitByShockwave = true;
        PVector normal = p.pos.copy().sub(pos);
        if (pullIn) {
          normal = pos.copy().sub(p.pos);
        } 
        normal.setMag(curMag);

        p.applyForce(normal);
      }
    }
  }

  void coolDisplay() {
    int iters = floor(curRad*0.15);
    float radStep = TWO_PI/iters;
    for (int i = 0; i < iters; i++) {
      float curAngle = radStep*i;
      PVector curPos = getPositionOnCircle(pos, curRad/2, curAngle);
      fill(255, 0, 0, map(lifetime, lifespan, 0, 30, 0));
      noStroke();
      ellipseMode(CENTER);
      ellipse(curPos.x, curPos.y, 20, 20);
    }
  }

  private PVector getPositionOnCircle(PVector center, float radius, float rad) {
    PVector p = new PVector((float) (center.x + radius * cos(rad)), (float) (center.y + radius* sin(rad)));
    return p;
  }

  boolean isDead() {
    return (lifetime < 0 || curRad > width);
  }
}
