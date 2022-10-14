# filters-audio-synthesizers
Music synth filters - Virtual Analog Modeling of the major music synthesizers’ architecture.

![Header](code.png)

## Abstract
An analysis and digital modeling of the major music synthesizers’ architectures is carried out. 
Given their original analog implementation, a common methodology for transforming their topologies to the digital domain is presented. 
For such purpose, linear approximations of the original analog architectures are carried out. 
Since the basic component featured in every synthesizer type is the analog LPF, which in turn is a continuous-time integrator, trapezoidal integration is featured as the optimal tool for converting this block to digital. 
By means of the trapezoidal rule, the developed digital synthesizer models optimally behave like their analog counterparts. 
The proposed method gives thus a common reference for a basic approach towards digital development of filters in music synthesizers.
