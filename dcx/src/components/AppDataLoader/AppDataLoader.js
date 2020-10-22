import React from "react";
import PropTypes from "prop-types";
import {
  Container,
  Card,
  CardContent,
  CardHeader,
  CardFooter,
  Icon,
  Label,
  Modal,
  ModalHeader,
  ModalContent,
  ModalFooter,
  Button,
  Textarea
} from "@svmx/ui-components-lightning";
import { Title } from "constants/AppConstants";
import DataLoader from "components/DataLoader";

import "./AppDataLoader.scss";

const AppDataLoader = props => {
  const { onClose, haltErrors = [], loaders } = props;
  const [haltError] = haltErrors;
  const { errorCode, message } = haltError || {};

  return (
    <div className="AppDataLoader">
      <div className="AppDataLoader__serviceMaxTitle">
        <svg width="216px" viewBox="-20 -20 490 80">
          <defs>
            <style>
              `.cls-1
              {"fill:#006;"}
              .cls-2
              {"fill:#31b700;"}'
            </style>
          </defs>
          <title>ServiceMax</title>
          <g id="Layer_2" data-name="Layer 2">
            <g id="Layer_1-2" data-name="Layer 1">
              <path
                className="cls-1"
                d="M47.67,40.49c0,13.06-9.87,18.45-23.59,18.45A45.54,45.54,0,0,1,0,52L7.67,39.59c4.17,2.86,11.43,5.72,16.74,5.72,5.63,0,7.43-1,7.43-3.68,0-2.12-2-3.43-9.72-5.22C8.33,33.22,1.71,29.47,1.71,18c0-10.77,8.74-18,22.54-18C34,0,41,2.37,47,6.61L39.35,19c-5.06-3.43-10.13-5.39-15.92-5.39-4.74,0-5.88,1.47-5.88,3.51s2,3.1,9.39,4.82C41.31,25.39,47.67,29.8,47.67,40.49Z"
              />
              <path
                className="cls-1"
                d="M136.85,58H120l-9.31-19.26h-4.47V58H91.53V.9h21.89C126.81.9,135.71,6,135.71,19.51c0,8.57-4,13.88-10.29,16.73Zm-15-38.12c0-3.59-2-6.12-6.94-6.12h-8.67V26.29h8.42C119.8,26.29,121.85,24,121.85,19.92Z"
              />
              <path
                className="cls-1"
                d="M169.08,58h-16L133.4.9h16.92Zm-6.33-28.53L172,.9h16.75L170.62,53.57Z"
              />
              <path
                className="cls-1"
                d="M258.64,44.16c-3.84,7.51-10.21,14.78-23.76,14.78-17,0-26-12.57-26-29.47C208.84,11.1,219.62,0,235,0c14,0,19.6,6,23.51,16.82l-14.36,5.63c-2-5.31-4-8.65-9.23-8.65-6.61,0-9.47,6.61-9.47,15.67,0,8.73,2.78,15.67,9.63,15.67,5,0,7.11-2.69,10.21-8.08Z"
              />
              <path
                className="cls-2"
                d="M318.53,29.22,318.85,58H304V.9h14.53l14.2,30.72L346.94.9H361.3V58H346.45l.32-28.82L332.65,60Z"
              />
              <path className="cls-1" d="M206.49,58.28h-16.3V.9h16.3Z" />
              <path
                className="cls-1"
                d="M299.9,58H261.14V.79h38.18L294,14.12H276.84v7.6h16.92V34.88H276.84V44.7h18.64Z"
              />
              <path
                className="cls-1"
                d="M89.55,58H50.8V.79H89L82.8,14.12H66.49v7.6H83.42V34.88H66.49V44.7H83.37Z"
              />
              <path
                className="cls-2"
                d="M414.57.9h18.37L468.06,58H450Zm2.77,51.89L430.48,32.6,439,46.09,431.88,58H402.1L399,48H381.86l-3.11,10h-17L382.51.9h16Zm26.18-40L451.21.9h17.08L451.73,26ZM395.16,35.43l-1.06-3.76c-2-7.34-2.94-10.45-3.67-14.28-.74,3.83-1.63,7-3.68,14.28l-1.06,3.76Z"
              />
            </g>
          </g>
        </svg>
      </div>
      <Container className="Container">
        <Card className="Card">
          <CardHeader
            title={
              window.configData && window.configData.Title
                ? window.configData.Title
                : Title
            }
          />
          <CardContent>
            <Icon category="svmx" icon="logo" size="large" />
          </CardContent>
          <CardFooter>
            <div>
              {loaders.map(loader => (
                <DataLoader loader={loader} />
              ))}
            </div>
          </CardFooter>
        </Card>
      </Container>
      {haltError && (
        <Modal isOpen={haltError} onClose={() => onClose()} zIndex={9003}>
          <ModalHeader
            title={
              window.configData && window.configData.Title
                ? window.configData.Title
                : Title
            }
          />
          <ModalContent className="slds-p-around--small">
            <Container>
              {errorCode && (
                <div>
                  <Label>
                    <b>Status : </b>
                    {isNaN(errorCode) ? errorCode : `HTTP ${errorCode}`}
                  </Label>
                </div>
              )}
              <Textarea name="ErrorDetails" value={message} />
            </Container>
          </ModalContent>
          <ModalFooter
            style={{ display: "flex", justifyContent: "space-around" }}
          >
            <Button type="brand" label="Close" onClick={() => onClose()} />
          </ModalFooter>
        </Modal>
      )}
    </div>
  );
};

AppDataLoader.propTypes = {
  loaders: PropTypes.arrayOf(PropTypes.shape()).isRequired,
  haltErrors: PropTypes.arrayOf(PropTypes.shape()),
  onClose: PropTypes.func.isRequired
};

export default AppDataLoader;
