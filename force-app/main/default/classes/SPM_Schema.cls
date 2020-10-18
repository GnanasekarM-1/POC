/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The class SPM_Schema which has all enums used accross SPM classes.
 *
 * @author Ramachandra Mohan
 * @version 15.59101
 * @since 2015
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan      14 Oct 2015     Created.
 *              Ramachandra Mohan      31 Mar 2016     Security fixes.
 *              Soumyaranjan Pati      25th Oct 2017   MTBF Related Code Added
 *****************************************************************************************************/
global with sharing class SPM_Schema {
    
    global enum ExpressionType 
    {
        QualificationCriteria,
        CriteriaForFirstTimeFixed,
        CriteriaForFirstTimeFixedUsingWorkDetail,
        FilterCriteria,
        WorkOrderCriteria,
        WorkOrderExcludeCriteria
    }
    
    global enum Report 
    {
        Recall,
        RepeatVisit,
        Utilization, 
        FirstTimeFix, 
        MeanTimeToRepair,
        UpDownTime,
        AverageResponseTime,
        ContractPenetration,
        MeanTimeToComplete,
        AccountSummary,
        MeanTimeBetweenFailure,
        TechnicianUtilization //Do not use this
    }
    
    global enum Field 
    {
        Id,
        Name,
        Technician, 
        ClosedOn, 
        Product, 
        ServiceGroup,
        CompletedDatetime, 
        InstallProduct,
        ScheduledDate, 
        ScheduledDatetime, 
        ServiceDuration, 
        DrivingTime, 
        Account,
        Component,
        TopLevel,
        DeadTime,
        LaborTime,
        WorkOrder,
        ServiceContract,
        ServiceContractStartDate,
        ServiceContractEndDate,
        Warranty,
        CreatedDate,
        StartDate,
        EndDate,
        BusinessHours,
        StartDateAndTime,
        EndDateAndTime,
        OrgDefaultBusinessHours,
        CompletedDate,
        SLATerms,
        TimeToInitialResponse,
        TimeToOnsiteResponse,
        TimeToResolve,
        TimeToRestore,
        ServiceDeliveredOn,
        SLAInitialResponseTime,
        SLAOnsiteResponseTime,
        SLARestorationTime,
        SLAResolutionTime,
        ClockExtensionMinutes,
        TimesheetID,
        Period,
        SubmittedLocation,
        User,
        NonProductiveTime,
        BreakTime,
        RecallQualifier,
        RepeatVisitQualifier,
        Location,
        hasPrimaryWorkOrder,
        RecallWindow,
        RepeatVisitWindow,
        RelatedWorkOrder,
        Team,
        Manager,
        isActiveTechnician,
        considerDownTimeFrom,
        Leaves,
        RecallAccount,
        RepeatVisitAccount,
        RecallLocation,
        RepeatVisitLocation,
        ProcessId,
        WorkOrderCase,    
        IssueCode,
        ftfSource
    }
}