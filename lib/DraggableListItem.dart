import 'package:flutter/material.dart';
import 'my_draggable.dart';

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
      return new LongPressMyDraggable<Data>(
          key: key,
          child: _getListChild(context),
          feedback: _getFeedback(index, context),
          data: data,
          onMove: onMove,
          onDragStarted: () {
            RenderBox it = context.findRenderObject() as RenderBox;
            onDragStarted(it.size.height, it.localToGlobal(it.semanticBounds.topCenter).dy);
          },
          onDragCompleted: onDragCompleted,
          onMyDraggableCanceled: (_, _2) {
            cancelCallback();
          });
    }
  }

  Widget _getListChild(BuildContext context) {
    return new MyDragTarget<int>(
      builder: (BuildContext context, List candidateData, List rejectedData) {
        return new Column(
          children: <Widget>[
            new SizedBox(
              height: data.extraTop,
            ),
            child,
            new SizedBox(
              height: data.extraBot,
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
    return new ConstrainedBox(
      constraints: new BoxConstraints(maxWidth: maxWidth),
      child: new Transform(
        transform: new Matrix4.rotationZ(0.0),
        alignment: FractionalOffset.bottomRight,
        child: new Material(
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
  double extraTop;
  double extraBot;

  Data(this.index, {this.extraTop = 0.0, this.extraBot = 0.0});
}
