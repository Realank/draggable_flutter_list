library dragable_flutter_list;

import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'DraggableListItem.dart';
import 'tools.dart';

typedef Widget WidgetMaker<T>(BuildContext context, int index);

class DragAndDropList extends StatefulWidget {
  final int rowsCount;

  final WidgetMaker itemBuilder;

  final CanDrag canDrag;

  final OnDragFinish onDragFinish;

  final CanAccept canBeDraggedTo;

  // dragElevation is only used if isItemsHaveCustomDraggableBehavior=false.
  // Otherwise, draggable items provide their own elevation/shadow.
  final double dragElevation;

  final ScrollController scrollController;

  DragAndDropList(this.rowsCount,
      {Key key,
      @required this.itemBuilder,
      this.onDragFinish,
      @required this.canBeDraggedTo,
      this.dragElevation = 0.0,
      this.canDrag,
      scrollController})
      : this.scrollController = scrollController ?? ScrollController(),
        super(key: key);

  @override
  State<StatefulWidget> createState() => new _DragAndDropListState();
}

class _DragAndDropListState extends State<DragAndDropList> {
  final double _kScrollThreshold = 160.0;

  bool shouldScrollUp = false;
  bool shouldScrollDown = false;

  double _currentScrollPos = 0.0;

  List<Data> rows = new List<Data>();

  //Index of the item dragged
  int _currentDraggingIndex;

  // The height of the item being dragged
  double dragHeight;

  SliverMultiBoxAdaptorElement renderSliverContext;

  Offset _currentMiddle;

  //Index of the item currently accepting
  int _currentIndex;

  bool isScrolling = false;

  double offsetToStartOfItem = 0.0;

  double sliverStartPos = 0.0;

  bool didJustStartDragging = false;

  // This corrects the case when the user grabs the card at the bottom, the system will always handle like grabbed on the middle to ensure correct behvior
  double middleOfItemInGlobalPosition = 0.0;

  @override
  void initState() {
    super.initState();
    populateRowList();
  }

  void populateRowList() {
    rows = [];
    for (int i = 0; i < widget.rowsCount; i++) {
      rows.add(Data(i));
    }
  }

  void _maybeScroll() {
    if (isScrolling) return;

    if (shouldScrollUp) {
      if (widget.scrollController.position.pixels == 0.0) return;
      isScrolling = true;
      var scrollTo = widget.scrollController.offset - 12.0;
      widget.scrollController
          .animateTo(scrollTo, duration: new Duration(milliseconds: 74), curve: Curves.linear)
          .then((it) {
        updatePlaceholder();
        isScrolling = false;
        _maybeScroll();
      });
      //TODO implement
//       Scrollable.ensureVisible(context, );
    }
    if (shouldScrollDown) {
      if (widget.scrollController.position.pixels ==
          widget.scrollController.position.maxScrollExtent) return;
      isScrolling = true;
      var scrollTo = widget.scrollController.offset + 12.0;
      widget.scrollController
          .animateTo(scrollTo, duration: new Duration(milliseconds: 75), curve: Curves.linear)
          .then((it) {
        updatePlaceholder();
        isScrolling = false;
        _maybeScroll();
      });
    }
  }

  @override
  void didUpdateWidget(DragAndDropList oldWidget) {
    super.didUpdateWidget(oldWidget);
    populateRowList();
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
      builder: (BuildContext context3, constr) {
        return new ListView.builder(
          itemBuilder: (BuildContext context2, int index) {
            return _getDraggableListItem(context2, index, context3);
          },
          controller: widget.scrollController,
          itemCount: rows.length,
        );
      },
    );
  }

  Widget _getDraggableListItem(BuildContext context2, int index, BuildContext context3) {
    var draggableListItem = new DraggableListItem(
      child: widget.itemBuilder(context2, rows[index].index),
      key: new ValueKey(rows[index]),
      data: rows[index],
      index: index,
      dragElevation: widget.dragElevation,
      draggedHeight: dragHeight,
      canDrag: widget.canDrag,
      onDragStarted: (double draggedHeight, double globalTopPositionOfDraggedItem) {
        _currentDraggingIndex = index;
        RenderBox rend = context3.findRenderObject();
        double start = rend.localToGlobal(new Offset(0.0, 0.0)).dy;
//        double end = rend.localToGlobal(new Offset(0.0, rend.semanticBounds.height)).dy;

        didJustStartDragging = true;
        _currentScrollPos = start;

        middleOfItemInGlobalPosition = globalTopPositionOfDraggedItem + draggedHeight / 2;

        sliverStartPos = start;

        // _buildOverlay(context2, start, end);

        renderSliverContext = context2;
        updatePlaceholder();
        dragHeight = draggedHeight;

        setState(() {
          rows.removeAt(index);
        });
      },
      onDragCompleted: () {
        _accept(index, _currentDraggingIndex);
      },
      onAccept: (int index) {
        _accept(_currentIndex, index);
      },
      onMove: (Offset offset) {
        if (didJustStartDragging) {
          didJustStartDragging = false;
          offsetToStartOfItem = offset.dy - middleOfItemInGlobalPosition;
          _currentScrollPos = offset.dy - offsetToStartOfItem;
        }
        _currentScrollPos = offset.dy - offsetToStartOfItem;
        double screenHeight = MediaQuery.of(context2).size.height;

        if (_currentScrollPos < _kScrollThreshold) {
          shouldScrollUp = true;
        } else {
          shouldScrollUp = false;
        }
        if (_currentScrollPos > screenHeight - _kScrollThreshold) {
          shouldScrollDown = true;
        } else {
          shouldScrollDown = false;
        }
        _maybeScroll();
        updatePlaceholder();
      },
      cancelCallback: () {
        _accept(_currentIndex, _currentDraggingIndex);
      },
    );
    return draggableListItem;
  }

  void _complete() {
    shouldScrollUp = false;
    shouldScrollDown = false;
    _currentIndex = null;
    _currentScrollPos = 0.0;
    _currentMiddle = null;
    _currentDraggingIndex = null;
    didJustStartDragging = false;
    offsetToStartOfItem = 0.0;
    middleOfItemInGlobalPosition = 0.0;
  }

  void _accept(int toIndex, int fromIndex) {
    if (_currentIndex == null || _currentMiddle == null) {
      setState(() {
        populateRowList();
      });
      _complete();
      return;
    }
    setState(() {
      shouldScrollDown = false;
      shouldScrollUp = false;
      if (fromIndex < rows.length) {
        rows[fromIndex].extraHeight = 0.0;
      }

      if (_currentMiddle.dy >= _currentScrollPos || rows.length == 0) {
        widget.onDragFinish(_currentDraggingIndex, toIndex);
      } else {
        widget.onDragFinish(_currentDraggingIndex, toIndex + 1);
      }
      populateRowList();
    });
    _complete();
  }

  void updatePlaceholder() {
    if (renderSliverContext == null) return;
    if (_currentDraggingIndex == null) return;
    RenderSliverList it = renderSliverContext.findRenderObject();
    double buffer = sliverStartPos;
    RenderBox currentChild = it.firstChild;
    print('current child $currentChild');
    if (currentChild == null) {
      return;
    }
    buffer += it.childMainAxisPosition(currentChild) + currentChild.size.height;
    while (_currentScrollPos > buffer) {
      if (currentChild != null) {
        var bufferChild = it.childAfter(currentChild);
        if (bufferChild == null) break;
        currentChild = bufferChild;
        buffer = it.childMainAxisPosition(currentChild) + currentChild.size.height + sliverStartPos;
      }
    }
    double middle = buffer - currentChild.size.height / 2;

    int index = it.indexOf(currentChild);

    if (!widget.canBeDraggedTo(_currentDraggingIndex, index)) return;

    _currentMiddle = new Offset(0.0, middle);

    final previousIndex = _currentIndex;
    final nextIndex = index;
    _currentIndex = index;
    final atTop = _currentScrollPos <= _currentMiddle.dy;

    if (nextIndex < rows.length &&
        previousIndex == nextIndex &&
        rows[nextIndex].isExtraAtTop == atTop &&
        rows[nextIndex].extraHeight == dragHeight) {
      return;
    }

    bool needUpdate = false;

    if (previousIndex != null && previousIndex < rows.length) {
      if (rows[previousIndex].extraHeight > 0.1) {
        rows[previousIndex].extraHeight = 0.0;
        needUpdate = true;
      }
    }

    if (nextIndex < rows.length) {
      if (dragHeight != null &&
          (absMinus(rows[nextIndex].extraHeight, dragHeight) > 0.1 ||
              rows[nextIndex].isExtraAtTop != atTop)) {
        rows[nextIndex].extraHeight = dragHeight;
        rows[nextIndex].isExtraAtTop = atTop;
        needUpdate = true;
      }
    }

    if (needUpdate) {
      setState(() {});
    }
  }
}
