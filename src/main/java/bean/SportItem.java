package bean;

public class SportItem {
    private Integer id;
    private Integer eventId;
    private String name;
    private String unit;
    private String recordType; // time / distance
    private String gender;
    // 展示用冗余字段（联表查询带出，不对应 sport_item 表列）
    private String eventName;

    public SportItem() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getEventId() { return eventId; }
    public void setEventId(Integer eventId) { this.eventId = eventId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public String getRecordType() { return recordType; }
    public void setRecordType(String recordType) { this.recordType = recordType; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public String getEventName() { return eventName; }
    public void setEventName(String eventName) { this.eventName = eventName; }
}
