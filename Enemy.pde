class Enemy
{
    PVector location;
    PVector velocity;
    
    Enemy()
    {
        float x = random(width);
        float y = random(20);
        location = new PVector(x, y);
        velocity = new PVector(0, 0);
    }
    
    void Display()
    {
        fill(255, 0, 40);
        noStroke();
        rect(location.x, location.y, 20, 20);
    }
    
    void Update()
    {
        if (location.x > width || location.y > height || location.x < 0 || location.y < 0)
        {
            Replace();
        }
        velocity.limit(5);
        location.add(velocity);
    }
    
    void aimButton(PVector force)
    {
        force.limit(7);
        velocity = force;
    }
    
    Boolean CheckIncomingBullet(Bullet b)
    {
        float d = dist(location.x, location.y, b.location.x, b.location.y);
        if (d < b.radius)
        {
            Replace();
            Btn.ammo += 3;
            Btn.radius = 70;
            EnemyKilled ++;
            if (Btn.health <= 9.8)
                Btn.health += 0.2;
            return true;
        }
        return false;
    }
    
    void Replace()
    {
        location.x = random(width);
        location.y = random(20);
    }
}
