# General information

## Topic description

The goal of the project is to create a command-line conversion program that can recognize certain sound samples from music in the form of a wave audio file (wav/mp3) and create an NBS file based on it (the own format of the Note Block Studio program). Basically, the goal is to recognize patterns in sound files containing Note Block patterns, at different times and pitches, with good results. The problem is very similar to the task of recognizing a MIDI file from a wave file, it can also be considered a special case of it.

## Conditions of creation

I am preparing this program as part of the Independent Laboratory subject of the BME engineering informatics course.

I write the program in Rust (I use version 1.75.0), for file formats and Fourier transformation I use some of the crates in the community library, which the package manager can automatically download before compilation.

The source code is available under the MIT license on [Github](https://github.com/4321ba/mp3-to-nbs).

# Introduction

## About the wave to midi problem in general

Recognizing sounds in wavy sound files is a common task, and there are already many solutions and programs for it. Such a program can be used, for example, if a composer wants to compose his music on a real instrument, but at the same time wants to post-work with digital tools. Or someone wants to write down an already finished piece of music, either so that it can be played, or so that it can be visualized. On YouTube, for example, these so-called piano tutorial videos, which people mostly watch not to learn to play the piano, but because they look good. One of the pioneers in this field was a program called [Synthesia](https://www.synthesiagame.com/), so this type of video is often called synthesia.

## A special case of this, wave to nbs

This project deals with a more specific, special case, where we are looking for pre-known sound samples in the sound file, whose pitch and length can be known quite precisely, and the samples are also known in advance. For this reason, in theory, much more precise recognition is possible than before. So far, the best automated approximation has been if we converted the wave audio file to MIDI using one of the MP3 (or other wave format) to MIDI converters available on the market, and then using a program called Note Block Studio (the format of which is our target format, nbs) we imported the MIDI file. None of the conversions are lossless, but especially the wave to MIDI part is imprecise, that is, it could be much more accurate, knowing the samples.

## Motivation

This would be beneficial in several ways, for example, with the knowledge of the sounds, you can make a visualization of the music [such](https://www.youtube.com/watch?v=L7TTUkqprQ0), which would not be possible without the sounds, only with the knowledge of the wavy sound file. Another possible use is if someone wants to rework the music, re-arrange it. For this, you also need to know what sounds are heard at which moments in time. [Here](https://www.youtube.com/playlist?list=PLuxIgMW_nasep2O39FE5GZay89wxcGhrL) there is, for example, a playlist of arrangements based on Note Block music.

## Outline a solution

During recognition, we first determine the moments in time that are worth examining more closely, i.e. at least one pattern will probably start to sound at that moment in time. This can be, for example, a sudden increase in volume because each sample is loud at the beginning and then fades away. We then compare all the pitches of all the known samples with the fraction of a second of the music to be recognized, and determine the instrument-pitch combinations that are worth further investigation and those that definitely do not sound. Then we run a library Nelder-Mead optimization with the potential sounds, which minimizes the sum of the absolute value of the difference between the potential sounds and the target. Then we get a volume for each of them, which is around 0, if the minimum search came up with no sound there. Then these sounds will be our tips for that moment in time.

## Document structure

After the Introduction, I will list the related works, where I will also present related own projects and other programs with a similar purpose. Then I will give a brief description of the format of the data used and what habits are associated with it. The search method, the minimum search algorithm used, the calculation of the distance, and the state space in which I am searching can be found under the following heading. Then comes the outline of the result, how well the program found which sounds, and how quickly. Finally, I summarize the project and describe further development opportunities.

# Related works

## MeloMIDI

[GitHub link.](https://github.com/4321ba/MeloMIDI) MeloMIDI is a previous project of mine that turns a wavy sound file into a MIDI file. It has a graphical interface and you can customize the MIDI file to be exported with the mouse over the spectrogram. In my opinion, it is wholecan also give good results.

## Other wave to midi programs

Without claiming to be exhaustive, I will list a few more programs with a similar purpose to MeloMIDI:

* [AnthemScore](https://www.lunaverus.com/) inspired MeloMIDI in part, knows more, but is proprietary. As soon as I tried it, it seemed like a good program.

* [WaoN](https://github.com/kichiki/WaoN) Very old, quite dead project, I used it a bit. Some Internet "wave to midi" converters use this, although they don't always admit it / make it easy to guess. The output from more complex files is not very usable, but it's a good little project and free / open source.

* [ISSE](https://sourceforge.net/projects/isse/) A program designed to separate sound sources, you can draw on the spectrogram which part belongs to which sound source, and based on this it creates two separate wave files with the two sources. It's also free / open source, and it hasn't been updated in a long time either.

* [Melodyne](https://www.celemony.com/en/melodyne/what-is-melodyne) I've never used it, but it looks good. And expensive.

## Noteblock Music Yoinker

[GitHub link.](https://github.com/4321ba/noteblock_music_yoinker) This is my own project, which consists of a Minecraft mod and python scripts for recording note block music into a custom csv-based format. The mod is quite inexpensive, it pours the music heard in the game into a csv file. This can then be processed in many ways with python scripts: concatenate / average several recordings of the same music to remove / reduce lag / inaccuracy caused by the network. This can be converted to a MIDI file, and also to an NBS file, and an NBS file can be converted to this csv format, which allows easier comparison. This may be useful in the future for this project as well, to compare the original and the recognized file.

With this program, I "recorded" a good part of the music of the Minecraft server called Wynncraft, and it is also [available](https://github.com/4321ba/Wynncraft_Noteblock_OST). This also raises legal questions, although I would like to argue that legally there should be no difference in the format in which music is available (eg mp3, midi or nbs). On YouTube, these musics are [available] with a Creative Commons Attribution license (reuse allowed) (https://www.youtube.com/playlist?list=PLyqkjDCr8kbI3CjNZimiri8shU1GbfJ6E), from an official source. This data set can be useful for accuracy testing later, although they only use 5 instruments, but also volume.

## Galaxy Jukebox

[GitHub link.](https://github.com/4321ba/Galaxy_Jukebox) This is also my own project, it can create a Minecraft redstone circuit from an NBS file that plays the given music in the game.

## Its synthesis

[GitHub link.](https://github.com/4321ba/synthesijava) Basics of programming 3 of my homework, a copy of Synthesia mentioned above, for visualizing MIDI files.

## Open Note Block Studio

[GitHub link.](https://github.com/OpenNBS/OpenNoteBlockStudio) Editor of the target format (nbs), you can use it to edit, create, view, export Minecraft Note Block music as a wave sound, and also as a redstone circuit that can be played in Minecraft ( although this part needs revision from several aspects).

## Nbswave

[GitHub link.](https://github.com/Bentroen/nbswave) ONBS's new wave exporter, because the old one is quite imprecise and the overclocking is not solved either.

# Format of data

## Input data

Wavy audio files are known, for example mp3, wav, ogg. Unpacking is done by the [babycat](https://crates.io/crates/babycat) library, we get the samples, `frame_rate_hz' per second, for example 44100. There is a question about what to do with multi-channel audio files, for now we will convert them to mono when importing. Noteblock music with stereo information is rare, but it can be used in the future to set the panning value of the sounds in the nbs file based on the recognition performed separately on the right and left channels (i.e. how far to the right/ the given voice comes from the left).

## Outgoing data

There are 16 types of instruments, but in previous versions of Minecraft there were only 5-6 for a long time, which is why the music on the Wynncraft server mentioned above is written with only 5 types of instruments. The program is currently tested with the recognition of 4 instruments, and thus it certainly works well, it can be easily expanded with other instruments in the future, although testing and fine-tuning of the optimization is probably necessary, and the question to be solved is how well the system can distinguish different instruments at the same height.

25 pitches are available within the game (2 octaves, [with equalized tuning](https://en.wikipedia.org/wiki/12_equal_temperament)). The editing program also allows the recording of other sounds, but indicates incompatibility in red. In our own program, this could be emulated in the future in such a way that, as a command line option, the user is able to recognize sounds outside of 2 octaves, but by default the program only tries 2 octaves. Currently ninches, the program tries to recognize the 2 octaves in the game.

Volume: represented between 0.0 and 1.0, the editing program between 0% and 100%. Its recognition is problematic if, in order to avoid overcontrol, the nbs to mp3 exporter, or simply the Studio itself, lowers the volume. Then all other recognition is also problematic if you do not lower the volume, and therefore there is overcontrol in many places. The volume can go above 1.0 if the same instrument is played at the same volume several times at the same time, this is quite common in the Wynncraft dataset and causes problems with MIDI file conversion (because it is not well supported for MIDI files), I would like to solve this better if I would do it again. In any case, this program is not prepared for the same instrument+pitch+moment being played multiple times. Currently there will be only one sound, maxed out at 100%. Currently, there are still more important problems.

Timing: the tempo is measured in tps, which is ticks per second. This is basically bpm, only not per minute, but per second, and we don't count fourths (=ta-kas), but rather 16ths (=riri-kas), but at least the smallest time difference found in music between two solo notes (=tick). Its usual value is 5, 10 and 20, there is even 6.75, instead of 6.67. Because in the past it was rounded to .25s by Studio, now anything can happen, although in practice I think the .25 rounding is still mostly used, and it is quite accurate. In the game, the above 4 can be played perfectly, but in the Studio you can write music at any tempo. The tempo is constant during the music, it cannot be changed, but due to the lag and inaccuracy in the recording (or the lameness of the exporter), I do not want to expect that the sounds will actually be heard exactly at the specified time. It's also better to perceive this dynamically, because it's easy to slip a tenth of a second to the end of a 2-minute piece of music, and recognition is already impaired. Of course, the recognized moments of time must be quantized afterwards and fitted to a specific tps, which currently must be given to the program, but in the future it would be good to recognize them with good accuracy. Initial recognition is already available, but it greatly impairs the result if the recognition is done incorrectly, but at the same time it is easy to enter by hand (as long as one knows about the given music), so at the moment it is better to enter it by hand, to hardcode it.

The output file format is Note Block Studio's own file format, nbs, documented [here](https://opennbs.org/nbs), but we use a library for export. Simply put, we need to output an array of 2D Note Blocks. time is on the horizontal axis, each column is called a tick. Each row is called a layer, and usually one instrument is placed only on it. I also did this in the exporter to make the file look nicer: the next instrument only starts when that line is free in all the ticks. The attached figure shows Note Block Studio, he indicates the different instruments with different colors.

![Screenshot of Note Block Studio layers](onbs_layers.png)

# Search method

## Pre-recognition

In order to minimize the state space of the library optimization algorithm, we try to recognize in advance those instrument-pitch combinations where sound is conceivable and those where it is not. This is done by subtracting the spectrogram of the sound sample from the spectrogram of the piece of music to be recognized (per element), then applying a ReLU-like function (f(x)=max(0,x)) to it, per pixel (i.e. for each given time-moment-frequency pair). Then the "errors" (or their square) are added up, and based on this we decide with a threshold whether to accept the possibility of the existence of the given sound. This ReLU is needed so that we don't penalize if there are many sounds in the piece of music, but penalize if the exact frequency that should be there isn't there.

## Optimization

After determining the pair of instrument-pitch pairs that potentially sound in the given tick, we use a library optimization algorithm to determine the state corresponding to the minimum of the error, where the error is the sum of the absolute values of the difference between the two spectrograms (~MAE), and the state is the volume per note , mostly between 0 and 1.

Among optimization algorithms, I tried Particle Swarm Optimization and the Nelder-Mead method, of which the latter seemed better, I will explain this below. They were mentioned because the error is the result of a complex calculation, which cannot be derived, or at least is very complicated. The essence of the Nelder-Mead method: in the case of n dimensions, it defines an n-dimensional tetrahedron with n+1 "vertices", then transforms the vertices step by step: one away (increased, reduced, or projected), or brings the vertices closer to each other, etc., depending on what error you get from the function we provide at those points.

# Results

## General rating

The program can quite successfully recognize one, nbswave-vel exported music, which can include harp, bass, snare and click instruments. On the other hand, it is necessary to specify the degree of compensation against overdrive and the tps in order to have a good recognition, it would be good to recognize these later by default. Further improvement of the recognition and testing of the program with more music, and later with several instruments, is necessary. Testing on sound files obtained with other exporters and recording methods is also necessary: better protect against over-control, small pitch shifts, and inaccuracies in timing. The program is able to take advantage of multithreading and runs in a reasonable amount of time using compile-time optimization, although additional runtime optimization would make sense. On my 8-9 year old intel laptop, it currently recognizes 1 minute of music in about 2 minutes.

Original:

![Screenshot of original music](onbs_original.png)

Recognized (same image as above):

![Screenshot of recognized music](onbs_layers.png)

## Comparison of optimization algorithms

The figure below compares the two tested methods (Nelder-Mead Method and Particle Swarm Optimization) based on the number of cost function calls and the error achieved.

![Diagram on comparison of optimization methods](optimization_comparison.png)

Of course, the use of both methods could be further optimized, with better initial values, a better swarm size than PSO, and fine-tuning of the parameters. But basically, Nelder-Mead was much faster and gave a better result. Moreover, even if I continue to run PSO with these parameters, it cannot give a better result than the error shown in the graph.

I ran 200 iterations for both methods, although this means different things for the two methods. With its 311 function calls, NM finished in 1.607s (=193.5 calls/s) and achieved a minimum cost of 0.02367, while PSO with its 8040 function calls in 39.295s (=204.6 calls/s) 0 , reached a minimum cost of 2434. So, in addition, between the calls, Nelder-Mead thought more, which is beneficial for this problem, since it is quite expensive to call the cost function.

The values found were as follows:

| Solution | No | There is | No | No | There is | No | No | There is | There is | There is | There is |
| -------- | -------- | ------ | ------- | -------- | ------ | -------- | ------- | ------ | ------ | ------ | ------ |
| NM | 0.007655 | 0.7186 | -0.0072 | -0.00057 | 0.7188 | 0.001538 | -0.0012 | 0.7197 | 0.7247 | 0.7165 | 0.7175 |
| PSO | 0.0 | 0.7189 | 0.0 | 0.0 | 0.7188 | 0.0 | 0.0 | 0.7184 | 1.0 | 0.7165 | 0.7195 |

# Summary

Overall, we successfully analyzed the wavy file, and found strong hints for solo voices at certain moments. We got to know the nbs format and the special features of Note Block music.

Going forward, it would be beneficial to implement the following development options without the need for completeness:

- recognition of several instruments
- testing with more music
- refinement of recognition, for example by adding a wave of sounds recognized in the previous tick during the current recognition
- Giving a more meaningful initial value to Nelder-Mead optimization based on the result of pre-recognition
- automatic tps and overcontrol compensation recognition
- command line switches for frequently changed parameters
- more robust recognition of audio files generated by other nbs to wave exporters / methods
- testing with other resource packs / soundfonts
- runtime optimization
- measurement of recognition accuracy on a larger data set, after the recognition is sufficiently good
- stereo recognition, the same sound multiple times at the same time
- try to recognize the layers on which the sounds are usually at the same volume, rounding these volumes to the recognized volume and using layer volumes