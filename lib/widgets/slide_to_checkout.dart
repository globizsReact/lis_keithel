import 'package:flutter/material.dart';
import 'package:lis_keithel/utils/theme.dart';

class SlideToCheckout extends StatefulWidget {
  final VoidCallback onSlideComplete;
  final bool isLoading;

  const SlideToCheckout({
    Key? key,
    required this.onSlideComplete,
    required this.isLoading,
  }) : super(key: key);

  @override
  _SlideToCheckoutState createState() => _SlideToCheckoutState();
}

class _SlideToCheckoutState extends State<SlideToCheckout>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isCheckedOut = false;
  late double _maxDragDistance;

  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // Color transition animation
    _colorAnimation = ColorTween(
      begin: AppTheme.orange,
      end: AppTheme.green,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Slide animation for when we reset or complete
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Listen to animation updates to rebuild the widget
    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update animation end value when widget rebuilds with new isLoading value
    if (widget.isLoading && !_isCheckedOut) {
      _animationController.forward();
    } else if (!widget.isLoading && !_isCheckedOut) {
      _animationController.reverse();
    }

    return LayoutBuilder(builder: (context, constraints) {
      // Calculate the maximum drag distance based on container width
      _maxDragDistance =
          constraints.maxWidth - 60; // 60 is button width + padding

      // Calculate animated slide position when resetting or completing
      double displayPosition = _isCheckedOut
          ? _maxDragDistance
          : _dragPosition > 0
              ? _dragPosition
              : _slideAnimation.value * 0; // Animated reset to 0

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: double.infinity,
            padding: EdgeInsets.all(3),
            height: 60,
            decoration: BoxDecoration(
              color: _isCheckedOut ? AppTheme.green : _colorAnimation.value,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                // Text inside slider with crossfade transition
                Positioned.fill(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0.0, 0.3),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: widget.isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'CHECKING OUT',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppTheme.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              ],
                            )
                          : Text(
                              "SLIDE TO CHECKOUT",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),

                // Draggable button with animated position
                AnimatedPositioned(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  left: displayPosition,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (!widget.isLoading && !_isCheckedOut) {
                        setState(() {
                          _dragPosition += details.delta.dx;
                          if (_dragPosition < 0) {
                            _dragPosition = 0;
                          } else if (_dragPosition > _maxDragDistance) {
                            _dragPosition = _maxDragDistance;
                          }

                          // Update animation controller based on drag progress
                          _animationController.value =
                              _dragPosition / _maxDragDistance;
                        });
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      if (!widget.isLoading &&
                          !_isCheckedOut &&
                          _dragPosition >= _maxDragDistance * 0.9) {
                        // Trigger when reached 90% of max distance
                        setState(() {
                          _dragPosition = _maxDragDistance; // Snap to end
                          _isCheckedOut = true;
                          _animationController
                              .forward(); // Ensure animation completes
                        });
                        widget.onSlideComplete();
                      } else if (!widget.isLoading && !_isCheckedOut) {
                        setState(() {
                          _dragPosition = 0; // Reset to start position
                          _animationController
                              .reverse(); // Reset color animation
                        });
                      }
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: widget.isLoading && _isCheckedOut
                              ? Image.asset(
                                  'assets/icons/arrowChecked.png',
                                  key: ValueKey<String>("checked"),
                                  width: 23,
                                )
                              : _isCheckedOut
                                  ? Icon(
                                      Icons.check,
                                      key: ValueKey<String>("check"),
                                      color: AppTheme.green,
                                      size: 23,
                                    )
                                  : Image.asset(
                                      'assets/icons/arrowCheckOut.png',
                                      key: ValueKey<String>("arrow"),
                                      width: 10,
                                    ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
