import java.util.Random;

class Wall
{
  PVector start;
  PVector end;
  PVector normal;
  PVector direction;
  float len;

  Wall(PVector start, PVector end)
  {
    this.start = start;
    this.end = end;
    direction = PVector.sub(this.end, this.start);
    len = direction.mag();
    direction.normalize();
    normal = new PVector(-direction.y, direction.x);
  }

  // Return the mid-point of this wall
  PVector center()
  {
    return PVector.mult(PVector.add(start, end), 0.5);
  }

  void draw()
  {
    strokeWeight(3);
    line(start.x, start.y, end.x, end.y);
    if (SHOW_WALL_DIRECTION)
    {
      PVector marker = PVector.add(PVector.mult(start, 0.2), PVector.mult(end, 0.8));
      circle(marker.x, marker.y, 5);
    }
  }

  @Override
    public boolean equals(Object o)
  {
    if (o == this)
      return true;
    Wall w = (Wall) o;
    return start == w.start && end == w.end;
  }
}


class Map
{
  ArrayList<Wall> walls;
  class Cell
  {
    Cell left;
    Cell right;
    Cell up;
    Cell down;
    float x;
    float y;
    Wall topWall;
    Wall leftWall;
    Wall bottomWall;
    Wall rightWall;

    public Cell(float x, float y)
    {
      this.x = x;
      this.y = y;
    }

    public String whichWall(Wall w)
    {
      if (w == topWall)
        return "top";
      else if (w == bottomWall)
        return "bottom";
      else if (w == leftWall)
        return "left";
      else if (w == rightWall)
        return "right";
      return "none";
    }
  }

  ArrayList<Cell> Cells = new ArrayList<Cell>();

  Map()
  {
    walls = new ArrayList<Wall>();
  }

  void addAllWalls(ArrayList<Wall> frontier, Cell c)
  {
    frontier.add(c.topWall);
    frontier.add(c.bottomWall);
    frontier.add(c.leftWall);
    frontier.add(c.rightWall);
  }

  void generate(int which)
  {
    walls.clear();
    for (float i = GRID_SIZE/2; i <= 800 - GRID_SIZE/2; i += GRID_SIZE) {
      for (float j = GRID_SIZE/2; j <= 600 - GRID_SIZE/2; j += GRID_SIZE) {
        Cell newCell = new Cell(i, j);
        Cells.add(newCell);
        int index = Cells.indexOf(newCell);
        if (index > 0)
        {
          Cell up = Cells.get(index-1);
          if (up.x == newCell.x)
          {
            up.down = newCell;
            newCell.up = up;
          }
        }
        if (index >= 600 / GRID_SIZE)
        {
          Cell left = Cells.get(index-600/GRID_SIZE);
          if (left.y == newCell.y)
          {
            left.right = newCell;
            newCell.left = left;
          }
        }
      }
    }

    for (Cell c : Cells)
    {
      PVector start = new PVector(c.x-GRID_SIZE/2, c.y-GRID_SIZE/2);
      PVector end = new PVector(c.x+GRID_SIZE/2, c.y-GRID_SIZE/2);
      Wall topWall = new Wall(start, end);
      map.walls.add(topWall);
      c.topWall = topWall;
      if (c.y > GRID_SIZE/2)
      {
        c.up.bottomWall = topWall;
      }
      start = new PVector(c.x-GRID_SIZE/2, c.y-GRID_SIZE/2);
      end = new PVector(c.x-GRID_SIZE/2, c.y+GRID_SIZE/2);
      Wall leftWall = new Wall(start, end);
      c.leftWall = leftWall;
      if (c.x > GRID_SIZE/2)
      {
        c.left.rightWall = leftWall;
      }
      map.walls.add(leftWall);
      if (c.x == GRID_SIZE/2 + GRID_SIZE * (800/GRID_SIZE - 1))
      {
        start = new PVector(c.x+GRID_SIZE/2, c.y-GRID_SIZE/2);
        end = new PVector(c.x+GRID_SIZE/2, c.y+GRID_SIZE/2);
        Wall rightmost = new Wall(start, end);
        map.walls.add(rightmost);
        c.rightWall = rightmost;
      }
      if (c.y == GRID_SIZE/2 + GRID_SIZE * (600/GRID_SIZE - 1))
      {
        start = new PVector(c.x-GRID_SIZE/2, c.y+GRID_SIZE/2);
        end = new PVector(c.x+GRID_SIZE/2, c.y+GRID_SIZE/2);
        Wall bottommost = new Wall(start, end);
        map.walls.add(bottommost);
        c.bottomWall = bottommost;
      }
    }
    //for (Cell c: Cells)
    //{
    //  System.out.println("Cell (" + c.x + ", " + c.y + ")");
    //if (c.leftWall != null)
    //  System.out.println("Left: (" + c.leftWall.start + ", " + c.leftWall.end + ")");
    //if (c.rightWall != null)
    //  System.out.println("Right: (" + c.rightWall.start + ", " + c.rightWall.end + ")");
    //if (c.topWall != null)
    //  System.out.println("Up: (" + c.topWall.start + ", " + c.topWall.end + ")");
    //if (c.bottomWall != null)
    //  System.out.println("Down: (" + c.bottomWall.start + ", " + c.bottomWall.end + ")");
    //}

    //for (Cell c: Cells)
    //{
    //  System.out.println("Cell (" + c.x + ", " + c.y + ")");
    //  if (c.left != null)
    //    System.out.println("Left: (" + c.left.x + ", " + c.left.y + ")");
    //  if (c.right != null)
    //    System.out.println("Right: (" + c.right.x + ", " + c.right.y + ")");
    //  if (c.up != null)
    //    System.out.println("Up: (" + c.up.x + ", " + c.up.y + ")");
    //  if (c.down != null)
    //    System.out.println("Down: (" + c.down.x + ", " + c.down.y + ")");
    //}
    Random random = new Random();
    int startIndex = random.nextInt(Cells.size());
    // println(Cells.size());
    // println(startIndex);
    ArrayList<Integer> visited = new ArrayList<Integer>();
    visited.add(startIndex);
    Cell startCell = Cells.get(startIndex);
    ArrayList<Wall> frontier = new ArrayList<Wall>();
    addAllWalls(frontier, startCell);
    while (frontier.size() > 0 && visited.size() != Cells.size())
    {
      Wall randomWall = frontier.get(random.nextInt(frontier.size()));
      for (Cell c : Cells)
      {
        String whichWall = c.whichWall(randomWall);
        if (whichWall != "none")
        {
          if (whichWall == "top")
          {
            if (c.up != null)
            {
              int wallIndex = Cells.indexOf(c);
              int topWallIndex = Cells.indexOf(c.up);
              if (visited.contains(wallIndex) && !visited.contains(topWallIndex))
              {
                walls.remove(randomWall);
                visited.add(topWallIndex);
                addAllWalls(frontier, c.up);
              }
              else if (!visited.contains(wallIndex) && visited.contains(topWallIndex))
              {
                walls.remove(randomWall);
                visited.add(wallIndex);
                addAllWalls(frontier, c);
              }
            }
          }
          else if (whichWall == "bottom")
          {
            if (c.down != null)
            {
              int wallIndex = Cells.indexOf(c);
              int bottomWallIndex = Cells.indexOf(c.down);
              if (visited.contains(wallIndex) && !visited.contains(bottomWallIndex))
              {
                walls.remove(randomWall);
                visited.add(bottomWallIndex);
                addAllWalls(frontier, c.down);
              }
              else if (!visited.contains(wallIndex) && visited.contains(bottomWallIndex))
              {
                walls.remove(randomWall);
                visited.add(wallIndex);
                addAllWalls(frontier, c);
              }
            }
          }
          else if (whichWall == "left")
          {
            if (c.left != null)
            {
              int wallIndex = Cells.indexOf(c);
              int leftWallIndex = Cells.indexOf(c.left);
              if (visited.contains(wallIndex) && !visited.contains(leftWallIndex))
              {
                walls.remove(randomWall);
                visited.add(leftWallIndex);
                addAllWalls(frontier, c.left);
              }
              else if (!visited.contains(wallIndex) && visited.contains(leftWallIndex))
              {
                walls.remove(randomWall);
                visited.add(wallIndex);
                addAllWalls(frontier, c);
              }
            }
          }
          else if (whichWall == "right")
          {
            if (c.right != null)
            {
              int wallIndex = Cells.indexOf(c);
              int rightWallIndex = Cells.indexOf(c.right);
              if (visited.contains(wallIndex) && !visited.contains(rightWallIndex))
              {
                walls.remove(randomWall);
                visited.add(rightWallIndex);
                addAllWalls(frontier, c.right);
              }
              else if (!visited.contains(wallIndex) && visited.contains(rightWallIndex))
              {
                walls.remove(randomWall);
                visited.add(wallIndex);
                addAllWalls(frontier, c);
              }
            }
          }
        }
      }
      frontier.remove(randomWall);
    }
  }

  void update(float dt)
  {
    draw();
  }

  void draw()
  {
    stroke(255);
    strokeWeight(3);
    for (Wall w : walls)
    {
      w.draw();
    }
    for (int i = 0; i < 800; i += GRID_SIZE) {
      for (int j = 0; j < 600; j += GRID_SIZE) {
        stroke(255);
        strokeWeight(3);
        point(i, j);
      }
    }
    //for (Cell c : Cells)
    //{
    //  stroke(255);
    //  strokeWeight(3);
    //  if (c.right != null)
    //  {
    //    line(c.x, c.y, c.right.x, c.right.y);
    //  }
    //  if (c.down != null)
    //  {
    //    line(c.x, c.y, c.down.x, c.down.y);
    //  }
    //}
  }
}
