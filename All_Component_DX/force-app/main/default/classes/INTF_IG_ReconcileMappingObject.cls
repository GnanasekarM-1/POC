global class INTF_IG_ReconcileMappingObject{

    public String baseobject { get; set; }
    public String baseobject_uid_field { get; set; }
    public List<ReconcileMappingField> fields_to_update { get; set; }
    
    public class ReconcileMappingField{

        public String baseobject_field_to_update { get; set; }
        public String baseobject_field_reference_uid { get; set; }
        public String referenceobject { get; set; }
        public String referenceobject_uid_field { get; set; }
    
    }

}