package bean;

public class Athlete {
    private Integer id;
    private Integer userId;
    private Integer eventId;
    private String department;
    private String name;
    private String gender;
    private Integer status; // 资格审查状态：0待审核 1通过 2驳回
    // 展示用冗余字段（联表查询带出，不对应 athlete 表列）
    private String username;
    private String eventName;

    public Athlete() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    public Integer getEventId() { return eventId; }
    public void setEventId(Integer eventId) { this.eventId = eventId; }
    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getEventName() { return eventName; }
    public void setEventName(String eventName) { this.eventName = eventName; }
}
