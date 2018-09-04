import 'package:flutter/material.dart';
import 'my_draggable.dart';
//import 'tools.dart';

typedef void OnDragStarted(double height, double topPosition);
typedef void OnDragFinish(int oldIndex, int newIndex);
typedef bool CanAccept(int oldIndex, int newIndex);
typedef bool CanDrag(int index);

class DraggableListItem extends StatelessWidget {
  final Data data;
  final int index;

  final double draggedHeight;
  final CanDrag canDrag;
  final OnDragStarted onDragStarted;
  final VoidCallback onDragCompleted;
  final MyDragTargetAccept onAccept;
  final ValueChanged<Offset> onMove;
  final VoidCallback cancelCallback;

  final double dragElevation;

  final Widget child;

  DraggableListItem({
    Key key,
    this.data,
    this.index,
    this.canDrag,
    this.onDragStarted,
    this.onDragCompleted,
    this.onAccept,
    this.onMove,
    this.cancelCallback,
    this.draggedHeight,
    this.child,
    this.dragElevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (canDrag != null && !(canDrag(index))) {
      return _getListChild(context);
    } else {
      return LongPressMyDraggable<Data>(
          key: key,
          child: _getListChild(context),
          feedback: _getFeedback(index, context),
          data: data,
          onMove: onMove,
          onDragStarted: () {
            RenderBox it = context.findRenderObject() as RenderBox;
            onDragStarted(it.size.height,
                it.localToGlobal(it.semanticBounds.topCenter).dy);
          },
          onDragCompleted: onDragCompleted,
          onMyDraggableCanceled: (_, _2) {
            cancelCallback();
          });
    }
  }

  Widget _getListChild(BuildContext context) {
    double nextTop = 0.0;
    double nextBot = 0.0;
    if (data.isExtraAtTop) {
      nextTop = data.extraHeight;
    } else {
      nextBot = data.extraHeight;
    }

    return MyDragTarget<int>(
      builder: (BuildContext context, List candidateData, List rejectedData) {
        return Column(
          children: <Widget>[
            SizedBox(
              height: nextTop,
            ),
            child,
            SizedBox(
              height: nextBot,
            ),
          ],
        );
      },
      onAccept: onAccept,
      onWillAccept: (data) {
        return true;
      },
    );
  }

  Widget _getFeedback(int index, BuildContext context) {
    var maxWidth = MediaQuery.of(context).size.width;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Transform(
        transform: Matrix4.rotationZ(0.0),
        alignment: FractionalOffset.bottomRight,
        child: Material(
          child: child,
          elevation: dragElevation,
          color: Colors.transparent,
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }
}

class Data {
  int index;
  double extraHeight;
  bool isExtraAtTop;

  Data(
    this.index, {
    this.isExtraAtTop = true,
    this.extraHeight = 0.0,
  });
}
