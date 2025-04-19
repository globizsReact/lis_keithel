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

class _SlideToCheckoutState extends State<SlideToCheckout> {
  double _dragPosition = 0.0;
  bool _isCheckedOut = false;
  late double _maxDragDistance;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Calculate the maximum drag distance based on container width
      _maxDragDistance =
          constraints.maxWidth - 60; // 60 is button width + padding

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3),
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.orange,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                // Text inside slider
                Positioned.fill(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: _isCheckedOut ? 10 : 30,
                      ),
                      child: Text(
                        widget.isLoading
                            ? "CHECKING OUT..."
                            : "SLIDE TO CHECKOUT",
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
                Positioned(
                  left: _dragPosition,
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
                        });
                        widget.onSlideComplete();
                      } else if (!widget.isLoading && !_isCheckedOut) {
                        setState(() {
                          _dragPosition = 0; // Reset to start position
                        });
                      }
                    },
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _isCheckedOut ? AppTheme.green : AppTheme.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: widget.isLoading && _isCheckedOut
                            ? Image.asset(
                                'assets/icons/arrowChecked.png',
                                width: 25,
                              )
                            : Image.asset(
                                'assets/icons/arrowCheckOut.png',
                                width: 10,
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
