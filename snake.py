#!/usr/bin/python
# -*- coding: utf-8 -*-

from math import sqrt, fabs
from random import randrange
import cv2

def downsize_image(image, width):
	(h, w) = image.shape[:2]
	height = int((width / float(w)) * h)
	return cv2.resize(image, (width, height))
	
def point_within_circle(point, circle_center, radius):
	distance = fabs(point[0] - circle_center[0]) ** 2 + fabs(point[1] - circle_center[1]) ** 2
	return sqrt(distance) < radius
	
def generate_new_target(max_width, max_height):
	return (randrange(30, max_width - 10), randrange(30, max_height - 10))
	
target = (-1, -1)
score = 0
fps = 18

# a pointer color bounds
greenLower = (75, 60, 50)
greenUpper = (85, 120, 255)

camera = cv2.VideoCapture(0)
counter = 0
timer = 0

while True:
	# grab the current frame
	(grabbed, frame) = camera.read()
	# flip the frame so it looks natural
	frame = cv2.flip(frame, 1)
	# skip if can't be grabbed
	if not grabbed:
		continue
	# resize the frame, blur it, and convert it to the HSV
	# color space
	frame = downsize_image(frame, 600)
	frame = cv2.GaussianBlur(frame, (11, 11), 0)
	hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
	
	# Place the first target if needed
	if target == (-1, -1):
		target = generate_new_target(frame.shape[1], frame.shape[0])

	# construct a mask for the pointer (of green color)
	mask = cv2.inRange(hsv, greenLower, greenUpper)
	# find contours in the mask and initialize the current
	# (x, y) center of the ball
	cnts = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[-2]
	center = None

	# only proceed if at least one contour was found
	if len(cnts) > 0:
		# find the largest contour in the mask, then use
		# it to compute the minimum enclosing circle and
		# its center
		c = max(cnts, key=cv2.contourArea)
		((x, y), radius) = cv2.minEnclosingCircle(c)
		center = (int(x),int(y))
		# the pointer's radius must be bigger than 10
		if radius > 10:
			# draw the circle
			cv2.circle(frame, (int(x), int(y)), int(radius), (0, 255, 255), 2, cv2.CV_AA)
			# and its center
			cv2.circle(frame, center, 5, (0, 0, 255), -1, cv2.CV_AA)
			# check if we approached a target
			if point_within_circle(target, (x,y), radius):
				score += 1
				target = generate_new_target(frame.shape[1], frame.shape[0])
				counter = 0

	# Adjust current time and target's lifetime
	timer += 1
	counter += 1
	# Move the target after a ~1 second delay
	if counter == int(fps * 1.1):
		target = generate_new_target(frame.shape[1], frame.shape[0])
		counter = 0
		
	# draw the target point
	cv2.circle(frame, target, 10, (255, 40, 255), -1, cv2.CV_AA)
	# draw the score and the timer value
	cv2.putText(frame, "Score: {}".format(score), (10, 30), cv2.FONT_HERSHEY_SIMPLEX,
		1, (0, 0, 0), 1, cv2.CV_AA)
	cv2.putText(frame, "Time: {}".format(timer / fps), (10, 70), cv2.FONT_HERSHEY_SIMPLEX,
	1, (0, 0, 0), 1, cv2.CV_AA)
	# draw the frame itself
	cv2.imshow("HandSnake", frame)
	if cv2.waitKey(fps) == ord("q"):
		break

# cleanup
camera.release()
cv2.destroyAllWindows()
