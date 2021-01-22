# feeding-assistant-robot-v2

This repository contains all related documents and files about Feeding Assistant Robot project. This project is being held for the Senior Design Project course at Mechatronics Engineering Department at Yildiz Technical University, Istanbul, Turkey. Also, this project is advised by Prof. Erhan Akdogan at Biomechatronics Laboratory.

Currently, our team consists of four senior Mechatronics Engineering students: [Mustafa UGUR](https://www.linkedin.com/in/mustafa-uğur-41b13310a), [Oguzhan YARDIMCI](https://www.linkedin.com/in/oguzhan-yardimci-505118144), [Cemil YILMAZ](https://www.linkedin.com/in/cemil-yılmaz-664a7b13b) and [Haluk BASI](https://www.linkedin.com/in/haluk-başı-9a2321143).


![alt text](https://github.com/Ugurmustafa97/feeding-assistant-robot-v2/blob/main/images/Robot3DView.PNG)

This robot arm helps disabled people while they are eating. It picks the food from the desired bowl and moves food to the mouth of the user. We helped from computer vision algorithms for human-machine interface operations. It doesn't show in the above image but there is a webcam next the to spoon, as it can be seen image below. 


![alt text](https://github.com/Ugurmustafa97/feeding-assistant-robot-v2/blob/main/images/camera-place.PNG)

Here are the basic workflow of the system:

1. System opens.
2. Robot arm moves to a position to look at the eyes of the user.
3. Computer vision algoritm decides to bowl that user wants to eat from informs the user with a loud warning about the decided one and moves to it.
  * If user closes his/her left eye 5 seconds, the robot arm moves to the first bowl.
  * If user closes his/her right eye 5 seconds, the robot arm moves to the second bowl.
  * If user closes his/her both eyes 3 seconds, the robot arm moves to the third bowl.
  
