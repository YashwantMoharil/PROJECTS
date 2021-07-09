#!/usr/bin/env python
# coding: utf-8

# In[1]:




import cv2
import numpy as np





def draw_point(event,x,y,flags,param):
    global pt1,topleft_clicked,bottomright_clicked
    
    if event == cv2.EVENT_LBUTTONDOWN:
        #Reset
        if topleft_clicked == True:                       #code for creating a point when clicked anywhere on screen which would become base point
            pt1 = (0,0)

            topleft_clicked = False
            
        if topleft_clicked == False:
            pt1 = (x,y)
            topleft_clicked = True
    pass
pt1 =(0,0)
topleft_clicked = False
cap=cv2.VideoCapture(0) # 0 signifies the default camera
cv2.namedWindow('t')
cv2.setMouseCallback('t',draw_point)
x_d=0.0
y_d=0.0
x_d_p=0.0
y_d_p=0.0

while(1):
    im, img = cap.read()
  
    #converting frame(img i.e BGR) to HSV (hue-saturation-value)

    hsv=cv2.cvtColor(img,cv2.COLOR_BGR2HSV)
    blue_lower=np.array([162,147,99],np.uint8)
    blue_upper=np.array([229,255,255],np.uint8)
    
    blue=cv2.inRange(hsv,blue_lower,blue_upper)
    
    kernal = np.ones((5 ,5), "uint8")
    blue=cv2.dilate(blue,kernal)
    
    
    contours,hierarchy=cv2.findContours(blue,cv2.RETR_CCOMP,cv2.CHAIN_APPROX_SIMPLE)
    if len(contours)>0:
        contour= max(contours,key=cv2.contourArea)
        area = cv2.contourArea(contour)
        if area>800: 
            x,y,w,h = cv2.boundingRect(contour)
          
            img = cv2.rectangle(img,(x,y),(x+w,y+h),(255,0,0),2)
            img=cv2.line(img,(pt1[0],pt1[1]),(int((2*x+w)/2),int((2*y+h)/2)),(0,255,0),2)
            blue = cv2.rectangle(blue,(x,y),(x+w,y+h),(255,0,0),2)
            x_d= (((2*y+h)/2)-pt1[1])
            y_d= (((2*x+w)/2)-pt1[0])
            s= 'x_d:'+ str(x_d)+ 'y_d:'+str(y_d)

            cv2.putText(img,s,(x-25,y-5),cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0,0,255),1,cv2.LINE_AA)
    	    
			
    
    
    
    
    
    
    if topleft_clicked:
        cv2.circle(img,center=pt1,radius = 5,color=(0,0,255),
                   thickness = -1)
    
			
    cv2.imshow('Binary image',blue)   
    cv2.imshow('t',img)

    if cv2.waitKey(1)==27:
        break

cap.release()
cv2.destroyAllWindows()

