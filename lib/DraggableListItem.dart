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
    final previousExtraHeight = data.previousExtraHeight;
    final previousExtraAtTop = data.previousIsExtraAtTop;
    data.previousExtraHeight = 0.0;
    return new MyDragTarget<int>(
      builder: (BuildContext context, List candidateData, List rejectedData) {
        return new Column(
          children: <Widget>[
            new SizedBox(
              height: data.isExtraAtTop ? data.extraHeight : 0.0,
            ),
            child,
            new SizedBox(
              height: data.isExtraAtTop ? 0.0 : data.extraHeight,
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
  double extraHeight;
  bool isExtraAtTop;
  double previousExtraHeight;
  bool previousIsExtraAtTop;

  Data(this.index,
      {this.isExtraAtTop = true,
      this.extraHeight = 0.0,
      this.previousIsExtraAtTop = true,
      this.previousExtraHeight = 0.0});
}
