from WebcamVideoStream import WebcamVideoStream
import pytesseract
import cv2
import numpy as np

print("[INFO] Starting Video Stream")
vs = WebcamVideoStream()
vs.start()
#time.sleep(2)

#Initialize Config for tesseract
#'-l eng Define the english wordfile
#config = ('-l eng')
config = ('-l digits --psm 10')


while True:
    frame = vs.read()
    #Color to GrayScale Filter
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    ##    #       cv2.imshow("Region Captured", frame)
    ##    #       cv2.imshow("Region Captured", frame)
    #cv2.imshow('gray', gray)


    #small Gaussian Blur Filter to filter out grainy Stuff
    gauss = cv2.GaussianBlur(gray, (5,5),0)
    #cv2.imshow('gauss', gauss)

    #canny detector
    #option, threshold1, threshold2
    canny = cv2.Canny(gauss,100,200)
    #canny = cv2.Canny(gauss,lower,upper)
    cv2.imshow('canny', canny)

    #corners = np.float32(canny)
    #find corners, minimum quality, minimum "abstand"
    #    corners = cv2.goodFeaturesToTrack(gauss, 25, 0.01, 10)
    #    corners = np.int0(corners)
    #
    #    for i in corners:
    #        x,y = i.ravel()
    #        cv2.circle(canny, (x,y), 3, 255, -1)
    #    cv2.imshow('corners', canny)
    # cv.CHAIN_APPROX_SIMPLE removes all redundant points eg. from a line
    #( _,cnts, hierarchy) = cv2.findContours(canny, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    #_, cnts = cv2.findContours(canny.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    cnts = cv2.findContours(canny.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)[0]
    cnts = sorted(cnts, key = cv2.contourArea, reverse = True)[:10]
    screenCnt = None
    ## loop over our contours
    #for c in cnts or []:
    for c in cnts:
        if cv2.contourArea(c) > 1000 :
    #    cv2.drawContours(frame, [c], -1, (0,255,0), 3)
    ##    # approximate the contour
            peri = cv2.arcLength(c, True)
            approx = cv2.approxPolyDP(c, 0.02 * peri, True)
    ##    # if our approximated contour has four points, then
    ##    # we can assume that we have found our screen
            if len(approx) == 4:
                screenCnt = approx
                cv2.drawContours(frame, [screenCnt], -1, (0, 255, 0), 3)
                #cv2.imshow("Region Captured", frame)
                x,y,width,height = cv2.boundingRect(screenCnt)
                # (x,y,w,h) = cv2.selectROI("Selection", frame)
                #cropped = frame[y: y + height , x: x + width] # both opencv and numpy are "row-major", so y goes first
                #cropped = canny[y: y + height , x: x + width] # both opencv and numpy are "row-major", so y goes first
                croppedframe = frame[y: y + height , x: x + width] # both opencv and numpy are "row-major", so y goes first
               # numConcat = np.concatenate((croppedframe, croppedframe), axis=1)
                #cv2.imshow("cropped", cropped)

                # Run tesseract OCR on image
                #text = pytesseract.image_to_string(cropped, config=config)
                #text = pytesseract.image_to_string(canny, config=config)
                #text = pytesseract.image_to_string(numConcat, config=config)
                text = pytesseract.image_to_string(croppedframe, config=config)

                # Print recognized text
                print(text)
                break
    ###cv2.imshow('corners', canny)
    cv2.imshow('frame', frame)
    key = cv2.waitKey(5) & 0xFF
    if key == 27:
        break

#Do Cleanup
vs.stop()
cv2.destroyAllWindows()
