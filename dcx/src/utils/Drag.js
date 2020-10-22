import "theme/index.scss";
import { getDisplayValue } from "utils/DCUtils";
import * as moment from "moment";
import { getUserTimeSettings } from "utils/DateAndTimeUtils";

class Drag extends window.bryntum.scheduler.DragHelper {
  static get defaultConfig() {
    return {
      // Don't drag the actual row element, clone it
      cloneTarget: true,
      mode: "translateXY",
      // Only allow drops on the schedule area
      // dropTargetSelector: '.b-timeline-subgrid',
      dropTargetSelector: [".b-sch-timeaxis-cell", ".b-sch-style-plain"],

      // Only allow drag of row elements inside on the unplanned grid
      // targetSelector: '.b-grid-row',
      targetSelector: ".rt-tr-group"
    };
  }

  construct(config) {
    const me = this;

    super.construct(config);

    me.on({
      drag: me.onTaskDrag,
      dragstart: me.onTaskDragStart,
      drop: me.onTaskDrop,
      thisObj: me
    });
  }

  removeClasses = (elList, className) => {
    const classListSelector = elList.querySelectorAll(`.${className}`);
    [].forEach.call(classListSelector, el => {
      el.classList.remove(className);
    });
  };
  addClasses = (elList, id, className) => {
    const idListSelector = elList.querySelectorAll(`[data-id="${id}"]`);
    [].forEach.call(idListSelector, el => {
      el.classList.add(className);
    });
  };

  onTaskDragStart({ event, context }) {
    const me = this;

    const mouseX = context.clientX;

    const proxy = context.element;

    context.wo = context.element.querySelector(".rt-td").innerText;
    me.schedule.element.classList.add("b-dragging-event");

    proxy.classList.add("drag-ghost");
    proxy.innerHTML = context.wo;
    me.onDragStart();
  }

  onTaskDrag({ event, context }) {
    const localContext = context;
    const me = this;
    context.element.style.transform = `translateX(${context.clientX}px) translateY(${context.clientY}px)`;
    const date = me.schedule.getDateFromCoordinate(
      window.bryntum.scheduler.DomHelper.getTranslateX(context.element),
      "",
      false
    );
    const currentTime = date === null ? "" : this.formatDate(date);
    localContext.element.innerHTML = `${context.wo} ${currentTime}`;
    const resource =
      context.target && me.schedule.resolveResourceRecord(context.target);
    this.removeClasses(me.schedule.element, "highlightRow");
    const dropTarget = context.target.className;
    if (dropTarget.includes) {
      if (dropTarget.includes("b-sch-timeaxis-cell")) {
        // Don't allow drops anywhere, only allow drops if the drop is on the timeaxis and on top of a Resource
        this.addClasses(
          me.schedule.element,
          localContext.target.closest(".b-grid-row").getAttribute("data-id"),
          "highlightRow"
        );
        localContext.valid = context.valid && Boolean(date && resource);
        localContext.isTreeDrop = false;
      } else if (
        (dropTarget.includes("b-tree-cell") ||
          dropTarget.includes("slds-form-element__label")) &&
        resource
      ) {
        this.addClasses(
          me.schedule.element,
          localContext.target.closest(".b-grid-row").getAttribute("data-id"),
          "highlightRow"
        );
        localContext.target.classList.add("highlightRow");
        localContext.valid = Boolean(date && resource);
        localContext.isTreeDrop = true;
      }
    }

    // // Save reference to resource and date, so we can use it in onTaskDrop
    localContext.resource = resource;
    localContext.dropDate = date;
    localContext.dropTime = date === null ? "" : this.formatDate(date, "time");
  }

  // Drop callback after a mouse up, take action and transfer the unplanned task to the real EventStore (if it's valid)
  onTaskDrop({ context, event }) {
    const me = this;

    if (context.valid) {
      me.onDropSuccess(context, getDisplayValue("TAG155"));
      // me.schedule.addEvent();
    }
    me.onDropFailure();
    me.schedule.element.classList.remove("b-dragging-event");
    this.removeClasses(me.schedule.element, "highlightRow");
    // else {
    //   window.bryntum.scheduler.WidgetHelper.toast(getDisplayValue('TAG199'));
    // }

    // const { task } = context;

    // const { target } = context;

    // If drop was done in a valid location, set the startDate and transfer the task to the Scheduler event store
    // if (context.valid) {
    //   // if (context.valid && target) {
    //   const date = me.schedule.getDateFromCoordinate(
    //     window.bryntum.scheduler.DomHelper.getTranslateX(context.element),
    //     'round',
    //     false,
    //   );

    // Try resolving event record from target element, to determine if drop was on another event

    // const targetEventRecord = me.schedule.resolveEventRecord(context.target);

    // if (date) {
    //   // Remove from grid first so that the data change
    //   // below does not fire events into the grid.
    //   me.grid.store.remove(task);

    //   task.setStartDate(date, true);
    //   task.resource = context.resource;
    //   me.schedule.eventStore.add(task);
    // }

    // Dropped on a scheduled event, display toast
    // if (targetEventRecord) {
    //   window.bryntum.scheduler.WidgetHelper.toast(`Dropped on ${targetEventRecord.name}`);
    // }

    //   me.context.finalize();
    // } else {
    //   me.abort();
    // }

    // me.schedule.element.classList.remove('b-dragging-event');
  }

  formatDate = (date, returnValue) => {
    if (returnValue === "time") {
      return moment(date).format(getUserTimeSettings("timeFormat"));
    }
    return moment(date).format(getUserTimeSettings("dateTimeFormat"));
  };
}

export default Drag;
