# feeding-assistant-robot-v2

This repository contains all related documents and files about Feeding Assistant Robot project. This project is being held for the Senior Design Project course at Mechatronics Engineering Department at Yildiz Technical University, Istanbul, Turkey. This project is advised by Prof. Erhan Akdogan at Biomechatronics Laboratory. Different than [feeding-assistant-robot-v1](https://github.com/Ugurmustafa97/feeding-assistant-robot-v1) this repository containts documents of a fully working system.

Currently, our team consists of four senior Mechatronics Engineering students: [Mustafa UGUR](https://www.linkedin.com/in/mustafa-uğur-41b13310a), [Oguzhan YARDIMCI](https://www.linkedin.com/in/oguzhan-yardimci-505118144), [Cemil YILMAZ](https://www.linkedin.com/in/cemil-yılmaz-664a7b13b) and [Haluk BASI](https://www.linkedin.com/in/haluk-başı-9a2321143).


![alt text](https://github.com/Ugurmustafa97/feeding-assistant-robot-v2/blob/main/images/Robot3DView.PNG)

This robot arm helps disabled people while they are eating. It picks the food from the desired bowl and moves food to the mouth of the user. We helped from computer vision algorithms for human-machine interface operations. It doesn't show in the above image but there is a webcam next the to spoon, as it can be seen image below. 


![alt text](https://github.com/Ugurmustafa97/feeding-assistant-robot-v2/blob/main/images/camera-place.PNG)

Here is the basic workflow of the system:

1. System opens.
2. Robot arm moves to a position to look at the eyes of the user.
3. Computer vision algoritm decides to bowl that user wants to eat from informs the user with a loud warning about the decided one and moves to it.
   - If user closes his/her left eye 5 seconds, the robot arm moves to the first bowl.
   - If user closes his/her right eye 5 seconds, the robot arm moves to the second bowl.
   - If user closes his/her both eyes 3 seconds, the robot arm moves to the third bowl.
4. The robot arm picks the food and goes back throughout to the user's face.
5. Computer vision algorithm publish the position of the user's mouth and the spoon at the end of the robot arm positions according to it.
6. User eats the food. And, this cyscle repeats from the second step.

The exploided view of the robot can be seen in the image below.

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

Servo motors used in the project are [Dynamixel-AX18A](https://emanual.robotis.com/docs/en/dxl/ax/ax-18a/). As webcam we used [Microsoft LifeCam HD-3000](https://www.microsoft.com/tr-tr/accessories/products/webcams/lifecam-hd-3000?activetab=overview%3aprimaryr2).The fifth part ([wheels](https://www.pololu.com/category/45/pololu-ball-casters)) are bought from a producer. The first part producted from [Cast Poliamid Sheet](https://www.metalreyonu.com.tr/en/products/cast-poliamid-sheet) by using machining. Other than, all parts are produced by 3D printing. For detailed information about 3D Design and production please don't hesitate contact with us.

In this project, the system uses computer vision algorithms for human-machine interface. For the selection of the bowl we used the time duration which the user closes his/her eyes as it was mentioned in the above. For this detection we trained two networks to detect left and right eye by using YOLO-V2. And, we also trained a network to detect the mouth. For the training, we used the team memebers' videos and all of the models worked accurately on the trials with team memebers. But, it is expected to work less efficiently with other uses, to overcome this problem existing big networks could be used or transfer learning methods could be used. But these works reamin in our future works list.

TO DO:
1. Add the eye-tracking images with black tapes, add mouth tracking images.
2. Add required codes, networks, e.g.
