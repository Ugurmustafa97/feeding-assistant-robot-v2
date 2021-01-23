# feeding-assistant-robot-v2

This repository contains all related documents and files about the Feeding Assistant Robot project. This project is being held for the Senior Design Project course at Mechatronics Engineering Department at Yildiz Technical University, Istanbul, Turkey. This project is advised by Prof. Erhan Akdogan at Biomechatronics Laboratory. Different than [feeding-assistant-robot-v1](https://github.com/Ugurmustafa97/feeding-assistant-robot-v1) this repository contains documents of a fully working system.

Currently, our team consists of four senior Mechatronics Engineering students: [Mustafa UGUR](https://www.linkedin.com/in/mustafa-uğur-41b13310a), [Oguzhan YARDIMCI](https://www.linkedin.com/in/oguzhan-yardimci-505118144), [Cemil YILMAZ](https://www.linkedin.com/in/cemil-yılmaz-664a7b13b) and [Haluk BASI](https://www.linkedin.com/in/haluk-başı-9a2321143).


![alt text](https://github.com/Ugurmustafa97/feeding-assistant-robot-v2/blob/main/images/Robot3DView.PNG)

This robot arm helps disabled people while they are eating. It picks the food from the desired bowl and moves food to the mouth of the user. We helped with computer vision algorithms for human-machine interface operations. It doesn't show in the above image but there is a webcam next the to spoon, as can be seen in the image below. 


![alt text](https://github.com/Ugurmustafa97/feeding-assistant-robot-v2/blob/main/images/camera-place.PNG)

Here is the basic workflow of the system:

1. System opens.
2. The robot arm moves to a position to look at the eyes of the user.
3. The computer vision algorithm decides to bowl that the user wants to eat from informs the user with a loud warning about the decided bowl and moves to it.
   - If the user closes his/her left eye for 5 seconds, the robot arm moves to the first bowl.
   - If the user closes his/her right eye for 5 seconds, the robot arm moves to the second bowl.
   - If the user closes his/her eyes for 3 seconds, the robot arm moves to the third bowl.
4. The robot arm picks the food and goes back throughout to the user's face.
5. The computer vision algorithm publishes the position of the user's mouth and the spoon at the end of the robot arm positions according to it.
6. The user eats the food. And, this cycle repeats from the second step.

The exploded  view of the robot can be seen in the image below.

![alt text](https://github.com/Ugurmustafa97/feeding-assistant-robot-v2/blob/main/images/exploded-view.jpg)

The items in the images are these:
1. Base plate
2. Bowl
3. Base retainer
4. Connecting holder
5. Wheel
6. Bottom plate
7. Connecting kit
8. First link
9. Second link
10. Servo motor
11. Manipulator kit
12. Spoon
13. Camera holder
14. Manipulator holder

Servo motors used in the project are [Dynamixel-AX18A](https://emanual.robotis.com/docs/en/dxl/ax/ax-18a/). As a webcam, we used [Microsoft LifeCam HD-3000](https://www.microsoft.com/tr-tr/accessories/products/webcams/lifecam-hd-3000?activetab=overview%3aprimaryr2). The fifth part ([wheels](https://www.pololu.com/category/45/pololu-ball-casters)) are bought from a producer. The first part was produced from [Cast Poliamid Sheet](https://www.metalreyonu.com.tr/en/products/cast-poliamid-sheet) by using machining. Other than that, all parts are produced by 3D printing. For detailed information about 3D Design and production please don't hesitate to contact us.

In this project, the system uses computer vision algorithms for the human-machine interface. For the selection of the bowl, we used the time duration in which the user closes his/her eyes as was mentioned above. For this detection, we trained two networks to detect the left and right eye by using YOLO-V2. And, we also trained a network to detect the mouth. For the training, we used the team members' videos and all of the models worked accurately on the trials with team members. But, it is expected to work less efficiently with other uses, to overcome this problem existing big networks could be used, or transfer learning methods could be used. But these works remain in the list of our future work.

We didn't put the outputs of the computer vision algorithms in here because it seems a bit funny. But you can check out those in the [images](https://github.com/Ugurmustafa97/feeding-assistant-robot-v2/tree/main/images) file. [Both_Moment.jpg](https://github.com/Ugurmustafa97/feeding-assistant-robot-v2/blob/main/images/Both_Moment.jpg) shows the output when the user closed his eyes for three seconds. [LeftEye_Moment.jpg](https://github.com/Ugurmustafa97/feeding-assistant-robot-v2/blob/main/images/LeftEye_Moment.jpg) shows the output when the user closed his left eye for five seconds.  [RightEye_Moment.jpg](https://github.com/Ugurmustafa97/feeding-assistant-robot-v2/blob/main/images/RightEye_Moment.jpg) shows the output when the user closed his right eye for five seconds. [mouthTracking5.jpg](https://github.com/Ugurmustafa97/feeding-assistant-robot-v2/blob/main/images/mouthTracking5.jpg) shows the output of the mouth tracking algorithm.

In the mouth tracking part, the computer vision algorithm detects the position of the mouth in the image and calculates the distance of it to the middle of the image in pixels. And, robot arm makes the required movements to align the mouth with the middle of the image. As it can be seen in the image below only the first joint is used to move the spoon in the vertical plane, and the second, third and fourth joints are used in combination to move the spoon in the horizontal plane.

![alt text](https://github.com/Ugurmustafa97/feeding-assistant-robot-v2/blob/main/images/robot_movement.jpg)

The system starts when we run [moveRobotArm_v13.m](https://github.com/Ugurmustafa97/feeding-assistant-robot-v2/blob/main/matlab-files/moveRobotArm_v13.m). But, even if you set all the entire system it may not work in your system because deep learning network files and some other files are related to the path. But, we think it could be resolved with some changes in the code.

In sum, if you want to build your own feeding assistant robot please contact us and we would love to help you throughout the assembly and the coding of the robot.

This feeding assistant robot system cost nearly 4000 Turkish Liras which is nearly equal to 550 U.S. dollars. Which makes the system much more affordable when it is compared with [Obi](https://meetobi.com/) or [Meal Buddy](https://www.performancehealth.com/meal-buddy-systems). So, anyone who has access to a 3D printer could build his/her own feeding assistant robot with the materials we provided in this repository.

## FUTURE WORKS
- We want to write the whole code again by using C++ and ROS and give a ROS package for the project.
- Also, we want to rewrite it in a Github repo to make it more trackable.
- We want to create a assembly instuction guide from scratch with a Youtube video that we show each parts manufacting from a 3D printer and their assembly.



