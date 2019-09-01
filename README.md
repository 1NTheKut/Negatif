# Negatif
This is simply a small iOS app that plays around with customizing colleciton view layouts and Core Image Filter. There are different SDKs and obviously Instagram, Facebook, yada yada yada that allow full customization of photos, but I wanted a better idea of the foundation of it all. I wanted to add in the ability to add frames to photos using `PhotoEditorSDK` but I want to focus on other projects. I will upload the png files for the frames and if anyone would like to contribute, they are more than welcome to!

Below are some of the features that I have been implemented. Though, this is a small app I used some `MVVM` architecture just to abstract a lot of the logic from the EdItImageViewController to its ModelController class so it is easier to read and follow. Please enjoy the images of Nick Cage :-)


### Homescreen View
![](https://github.com/turtlenecksweater/Negat-f/blob/master/homescreen.GIF)

### Editing View
![](https://github.com/turtlenecksweater/Negat-f/blob/master/edit.GIF)


#### There are a few places that can use improvement (any suggestions would be appreciated as well):
1. [] Modifying image filter value ranges. For example, if you use the *Contrast* feature, the lowest value will make the image a grey color.
2. [] Fixing the way images are reverted when a user wants to completely start from sratch. When they are starting from the original image and then try a filter, it will filter based upon the most recent filter added instead of filtering from the original photo.
3. [] Fixing memory issues. I am using Metal/MetalKit but there is room for improvement.






