import React, { useEffect, useRef, useState } from "react";
import { PropTypes } from "prop-types";
import { CircularProgressbar, buildStyles } from "react-circular-progressbar";
import "react-circular-progressbar/dist/styles.css";
import "./ReloadData.scss";

const defaultProps = {
  autorefresh: false,
  refreshtime: 7
};

const propTypes = {
  autorefresh: PropTypes.bool,
  refreshtime: PropTypes.number,
  view: PropTypes.shape({}).isRequired,
  viewSelectionChanged: PropTypes.func.isRequired
};

const ReloadData = props => {
  const {
    autorefresh,
    loading,
    refreshtime,
    view,
    viewSelectionChanged
  } = props;

  const maxValue = refreshtime * 60;
  const [seconds, setSeconds] = useState(maxValue);
  const [refreshInterval, setRefreshInterval] = useState(refreshtime);

  const useInterval = (callback, autoRefresh, refreshtime, delay) => {
    const savedCallback = useRef();
    const prevRefreshInterval = useRef();

    useEffect(() => {
      savedCallback.current = callback;
      prevRefreshInterval.current = refreshInterval;
    });

    useEffect(() => {
      function tick() {
        savedCallback.current();
      }

      const id = setInterval(tick, Math.floor(delay) * 1000);
      if (!autoRefresh || loading) {
        clearInterval(id);
        setSeconds(maxValue);
      }
      if (prevRefreshInterval.current !== refreshtime) {
        setSeconds(maxValue);
        setRefreshInterval(refreshtime);
      }
      return () => clearInterval(id);
    }, [autoRefresh, delay, loading, refreshtime]);
  };

  useInterval(
    () => {
      if (seconds <= 0) {
        setSeconds(maxValue);
        viewSelectionChanged(view, true);
        return;
      }
      setSeconds(seconds - 1);
    },
    autorefresh,
    refreshtime,
    1
  );

  return (
    <CircularProgressbar
      counterClockwise
      value={seconds}
      text={`${seconds}`}
      maxValue={refreshtime * 60}
      background
      backgroundPadding={6}
      styles={buildStyles({
        backgroundColor: "#3e98c7",
        pathColor: "#fff",
        textColor: "#fff",
        textSize: "2rem",
        trailColor: "transparent"
      })}
    />
  );
};

ReloadData.propTypes = propTypes;
ReloadData.defaultProps = defaultProps;
export default ReloadData;
