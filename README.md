[![en](https://img.shields.io/badge/lang-en-red.svg)](./README.md) [![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](./README.pt-BR.md)

<div align="center">
  <img src="https://raw.githubusercontent.com/BrunoNFL/brunonfl.github.io/master/depictions/com.brunonfl.s8edge/icon%403x.png" width="80" alt="S8Edge Icon">
  <h1>S8Edge</h1>
</div>

A simple and lightweight jailbreak tweak that brought the popular curved "edge" screen aesthetic to iPhones. At its peak, this was my most downloaded tweak, responding to a popular design trend in the community.

---

<p align="center">
  <img src="https://raw.githubusercontent.com/BrunoNFL/brunonfl.github.io/master/depictions/com.brunonfl.s8edge/Screenshots/1.jpg" width="200" alt="S8Edge Screenshot 1">
  <img src="https://raw.githubusercontent.com/BrunoNFL/brunonfl.github.io/master/depictions/com.brunonfl.s8edge/Screenshots/2.jpg" width="200" alt="S8Edge Screenshot 2">
  <img src="https://raw.githubusercontent.com/BrunoNFL/brunonfl.github.io/master/depictions/com.brunonfl.s8edge/Screenshots/3.jpg" width="200" alt="S8Edge Screenshot 3">
</p>

---

## 💡 The Concept

This project wasn't about adding complex features. It was a direct response to a request from the `/r/jailbreak` subreddit. At a time when phones like the Samsung Galaxy S8 were popularizing curved-edge screens, a user wanted a simple way to bring that aesthetic to their iPhone.

S8Edge was created as a simple, elegant, and purely cosmetic solution to simulate that look and feel.

## ✨ Features

* **Simulated Curved Edges:** The tweak adds a clean overlay to the screen that gives the illusion of curved "edge" display borders.
* **Rounded Corners:** A key part of the effect was rounding the corners of the display, which became the most popular aspect of the tweak.
* **Black & White Color Options:** Users could choose between a black or white overlay to perfectly match the color of their device's bezel.
* **Lightweight & Efficient:** Designed to be a simple image overlay, the tweak had virtually zero impact on performance or battery life.

## 🛠️ Technical Implementation

The tweak's effectiveness came from its simple and clever implementation.

* **Top-Level Window Overlay:** The entire effect is achieved by creating a single, full-screen `UIWindow` that sits on top of all other content (`UIWindowLevelAlert`). This window is transparent and non-interactive.
* **Image-Based Mask:** The "curved" effect is created by adding a `UIImageView` to this window. The image is a simple PNG mask with transparent corners and edges, which overlays the system UI to create the illusion.
* **Minimalistic Code:** The entire tweak consists of a single class, making it incredibly lightweight and stable. It's a testament to achieving a popular visual effect with the simplest possible solution.

## 💻 How to Compile

1.  Ensure you have the [Theos toolchain](https://theos.dev/) installed.
2.  Clone the repository: `git clone https://github.com/BrunoNFL/s8edge.git`
3.  Run `make package` in the project's root directory.

**(Note: This project was developed for older versions of iOS and may require updates to compile and run on modern systems.)**
