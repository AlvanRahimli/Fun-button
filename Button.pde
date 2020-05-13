class Button
{
    PVector location;
    PVector velocity;
    PVector acceleration;
    PVector shooterDirection;
    int radius;
    int mass;
    ArrayList<Bullet> Bullets;
    float health;
    int ammo;
    Boolean canFire;
    
    Button()
    {
        location = new PVector(width/2, height/2);
        velocity = new PVector(0, 0);
        acceleration = new PVector(0, 0);
        radius = 70;
        mass = 1000;
        Bullets = new ArrayList<Bullet>();
        health = 10;
        ammo = 100;
        shooterDirection = new PVector(0, -1);
        canFire = true;
    }
    
    void Display()
    {
        fill(150, 255, 50);
        noStroke();
        ellipse(location.x, location.y, radius, radius);
        
        // Draw PP
        fill(255);
        stroke(150, 255, 50);
        strokeWeight(map(radius, 0, 70, 0, 15));
        float len = map(radius, 0, 70, 0, 40);
        line(location.x, location.y, location.x + shooterDirection.x*len, location.y + shooterDirection.y*len);
        for(Bullet blt : Bullets)
        {
            blt.Update();
            blt.Display();
        }
    }

    void Update()
    {
        velocity.limit(8);
        velocity.add(acceleration);
        location.add(velocity);
    }
    
    void checkBounds()
    {
        if(location.x < 0)
        {
            triangle(5, location.y, 15, location.y - 5, 15, location.y + 5);
            if(location.x < -width/4)
                location.x = -width/4;
        }
        if(location.y < 0)
            location.y = 0;
        if(location.x > width)
        {
            triangle(width - 5, location.y, width - 15, location.y - 5, width - 15, location.y + 5);
            if(location.x > width + width/4)
                location.x = width + width/4;
        }
        if(location.y > height)
        {
            triangle(location.x, height - 5, location.x - 5, height - 15, location.x + 5, height - 15);
            if (location.y > height + height/4)
                location.y = height + height/4;
        }
    }

    void DrawHealthBar()
    {
        strokeWeight(0);
        // Health bar:
        fill(255, 200);
        textSize(18);
        text("Health:", 20, height - 54);
        fill(0);
        rect(20, height - 50, 208, 30);
        fill(255, 200);
        rect(24, height - 46, Btn.health * 20, 22);
    }
    
    void aim(PVector aim)
    {
        aim.normalize();
        shooterDirection = aim;
    }
    
    void applyForce(PVector force)
    {
        acceleration.mult(0);
        PVector acc = force.div(mass);
        acceleration.add(acc);
    }
    
    void Fire()
    {
        if (ammo > 0 && canFire)
        {
            Btn.radius -= 5;
            
            Bullet blt = new Bullet(
                new PVector(location.x + shooterDirection.x * radius, location.y + shooterDirection.y * radius),
                PVector.mult(shooterDirection, 15),
                random(20, 15)
            );
            Bullets.add(blt);
            ammo --;
            
            // apply impact
            velocity.add(PVector.mult(shooterDirection, -1));
        }
    }
    
    Boolean CheckHealth(Enemy e)
    {
        float d = dist(location.x, location.y, e.location.x, e.location.y);
        if (d < radius)
        {
            health --;
            return true;
        }
        return false;
    }
}
