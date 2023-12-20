# CSCI 5619 VR Final Project, Fall 2023
Noah Hendrickson, Zitong Xiao

## Part 1: Aperture Selection

- Idea from Assignment 3 and Lecture 16,17.
- It has a retractable spindle and a scalable sphere marker.
- Users can interact with virual environment over long distances. 
- The interaction methods and operations are:
    - Use the right hand controller, press `by_button` to stretch the spindle, press `ax_button` to pull back the spindle.
    - Use the right hand controller, while press the `trigger_button`, press `by_button` and `ax_button` to scale the marker.
    - When the marker is in contact with an interactive object, the object is highlighted, press `grab_button` to grab the object.
    - While grabing the object, stretch or pull back the spinle to replace the object.
    - While grabing the object, press `primary_button`  look at the object(board) head-on.
    - While press the `trigger_button`, pull up the `primary joysticks` to teleport to marker's position. Pull down the `primary joysticks` to teleport to spawn position.
    - Pull right the `primary joysticks` to change the color of marker. Pull left the `primary joysticks` to change the color back to previous color. 

## Part 2: Board Generation / Manipulation

- Upon entering the world, boards will be generated in front of the user
- The center board is the "root" board
- Moving this root board causes a highlighted green baord to appear in its place
- Using the aperture selection, user can pick up any surrounding board and place 
   the board in the highlighted area. <br>
   This board will be the new root board and subsequent boards will be generated
   based on that board state.

## Part 3: Board Stats

- Boards can be picked up and moved to a pedastal, initially to the right of the user. 
- Once a board is placed, the application will think for a bit while it calculates
board states. <br>Once it is done calculating, the wins, losses, draws, and total board
states spanning from that board will be displayed.

## Part 4: Depth Control

- Both physical board generation and stats generation are dependent on a depth value.
- A 1dof menu was implemented to control these values. 
- The current menu item and value can be seen floating above each controller.
   - This value initially starts out as the physical board depth
- If the user holds the `trigger_button` of the controller that the aperture selector is 
not on and moves the joystick left or right, the value will increase or decrease.
- If the user holds the `trigger_button` and moves the joystick up or down, the mode will 
switch to the other depth mode. 
   - i.e. if the aperture selector is in the right hand and the user wants to switch
   from physical depth to stats depth changing, the user can hold the left controller
   `trigger_button`, and move the joystick up or down fully once. <br>
   - if the user then wants to change the value of the depth, they can continue
   to hold down the `trigger_button` and move the joystick left or right to increase or decrease respectively.
- The depth of the stats board has no upper limit and a lower limit of 0.
   - Going beyond 7 or 8 is not recommended as it can take a long time to calculate.
- The depth of the physical generation can be either 1 or 2. If it goes beyond this,
the application slows down heavily.

## Part 5: Controller Switching

- Taking an idea from google's tilt brush, the controller with the aperture selector
can be changed by moving together the bottoms of the controllers sufficiently fast enough.
   - In code, the speed has to be 1 m/s but the user will naturally get the hang of 
switching hands.
   - The controllers also have to be in sufficiently opposite directions from each other.
   - A good rule of thumb is if they are at least 90 degrees apart it should work.
- When this is done, any functionality of the aperture controller is moved to the other
controller and any functionality for the 1dof controller is moved to the opposite controller.

## AI-generated code

   - In Marker script line 72, `var random_color = Color(fmod(randf(), 1.0), fmod(randf(), 1.0), fmod(randf(), 1.0))` is created by AI because I don't know can only used by integer in GDscript.

## Third Party Assets

   `N/A`
