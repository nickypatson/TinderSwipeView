
# TinderSwipeView

Swipe view inspired by Tinder

## Screenshot

![Alt text](/playback.gif?raw=true "Optional Title")

```swift
func createDraggableViewWithData(at index: Int , value :String) -> TinderCard {

let card = TinderCard(frame: CGRect(x: 10, y: 0, width: viewTinderBackGround.frame.size.width - 20 , height: viewTinderBackGround.frame.size.height - 40) ,value : value)
card.delegate = self
return card
}
```

## Requirements

```
* Swift 4
* XCode 9
* iOS 8.0 (Min SDK)
```

## Author

Nicky Patson

[HomePage](http://about.me/nickypatson)

<mail.nickypatson@gmail.com>


## License

GradientSlider is available under the MIT license. See the LICENSE file for more info.

