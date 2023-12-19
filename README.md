<!-- # Assignment 4: Virtual Locomotion

**Due: Friday, December 1, 11:59pm CDT**

In this assignment, you will extend the custom view-directed steering script developed in [Lecture 20](https://mediaspace.umn.edu/media/t/1_j07xqm14) with other types of virtual locomotion.

## Submission Information

You should fill out this information before submitting your assignment. 

1. **Ready for Grading**. When your assignment is complete, you should change the line below to YES and then push to GitHub. This will signal to the TA that your assignment is ready to be graded. If the submission is completed after the due date, the timestamp of the commit will be used to determine how many late points will be applied.

   `YES`

2. **Third Party Assets**. List the name and source of any third party assets that you added, such as models, images, sounds, or any other content used that was not created by you.

   `The kiwi as usual from the same person it always is.`

3. **Grading Instructions**. Please provide a brief description of your VR experience, identify the interaction techniques you implemented, and provide any usage instructions needed for the person grading your assignment.

   The normal functionality was implemented as the writeup requested. Both controllers
   can control the movement and turning switching with the buttons. The obstacle course
   includes some initially red rings that the user has to pass through. Once passed through,
   the color of the inside of the ring changes from red to green so you will know how 
   many rings you've passed through. Beware, though, Kiwis roam the realms and will reset
   all of your progress! If you run into any of the kiwis roaming the arena, you will 
   be teleported back to the starting point and all of the gates you have gone through
   will be reset. Most kiwis have set, similar paths around their gates, though with slight
   variations in speed. One kiwi walks through the gates at a slightly faster speed and has a 
   much more winding path, watch out for him or stay safe behind him!

4. **Wizard Bonus Functionality**. If you completed the bonus challenge, then please provide a brief description of the additional functionality that you would like us to consider for extra credit.

   In order to implement better switching between movement modes, I implemented
   a wrist attached menu for swapping modes. The currently activated mode will appear
   in green and the other will appear in red. Circular selectors at the tips of each 
   controller can be used to select a new mode by putting the circle onto the 
   button and pressing in the trigger to select the new mode. You can select with either
   the right or left controller and the opposite arm's info will update accordingly. 

## Prerequisites

To work with this code, you will first need to install [Godot Engine 4.1.2](https://godotengine.org/).

This assignment is intended to completed with a Quest headset directly connected to a PC using Oculus Link (USB-C cable or WiFi). If your personal computer does not support this, then you can check out one of the VR graphics laptops from CSE-IT.

## Rubric

Graded out of 20 points. Partial credit is possible for each step.

**Part 1: Hand-Directed Steering Mode**

- Add hand-directed steering to the locomotion script. In this mode, the user should be moved forward in the direction they are pointing with a controller instead of the camera view direction. You can choose either the left hand or right hand; it does not need to work with both. (4)
- Add the ability to toggle back and forth between hand-directed steering and the original view-directed steering mode by pressing the `ax_button` on the controller. (2)

**Part 2: Snap Turn Mode**

- The original script implements smooth turning when the user moves the thumbstick left or right.  Add a snap turn mode that will instantaneously turn by 45 degrees when they move the thumbstick almost all the way (e.g., trigger values of -.9 and .9 would be reasonable).  The user must then return the thumbstick back to the center dead zone before they can snap turn again.  (4)
- Add the ability to toggle back and forth between snap turn and the original smooth turn mode by pressing the `by_button` on the controller. (2)

**Part 3**: **Obstacle Course**

The starter scene contains a simple environment containing just the ground plane with a texture suitable for debugging.  Similar to previous assignments, you should replace this with a more interesting virtual environment to use as a locomotion testbed. 

- The environment should contain at least four target objects that the user needs to move to. (2)
- When the user gets sufficiently close to a target object, it should be activated. (2)

You have a lot of freedom with how to design this obstacle course.  For example, the targets could be objects to collect that get "picked up" (disappear) when the user activates them. Alternatively, the targets could be hoops or doorways that change color or appearance when the user moves through them. 

- The environment should contain at least four moving obstacles that the user should avoid. (2)
- When the user collides with an obstacle, they should be moved back to their start position. (2)

You can make the obstacles any size and shape you want, as long as they create at least some challenge for the user to avoid as they are traveling to the targets. You are also free to implement them using pre-scripted animations (e.g., traveling back and forth between two points) or dynamic movements (e.g., "chasing" the user).  However, don't make the obstacle course too difficult... it shouldn't be impossible for the user to complete it successfully!

**Bonus Challenge:** For two points of extra credit, you can implement a spatial user interface to switch between the movement and turn modes implemented in Parts 1 and 2. For example, you could try adding a handheld laser pointer to select 3D objects that activate the different locomotion modes. This is just one example, however, and you have a lot of freedom to come up with other ideas. The only requirement is that it needs to some sort of 3D interaction, not just pressing a controller button. (+2)

**Documentation:** Make sure to document any third party assets or code used in this assignment at the top of this readme file. One point will be deducted for using third party assets without attribution. This only refers to additional assets that you find on your own; you don't need to document anything that is already provided along with the assignment. (-1)

## License

Material for [CSCI 5619 Fall 2023](https://canvas.umn.edu/courses/391288/assignments/syllabus) by [Evan Suma Rosenberg](https://illusioneering.umn.edu/) is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/). -->
