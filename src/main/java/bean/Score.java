package bean;
import java.util.Date;

public class Score {
    private Integer id;
    private Integer itemId;
    private Integer athleteId;
    private Double value;
    private String unit;
    private Integer isFoul;    //0正常 1犯规
    private Integer isFinished;//0未完成 1完成
    private Integer isRecord;//0普通 1破纪录
    private Integer rank;
    private Date createTime;
    // 展示用冗余字段（联表查询带出，不对应 score 表列）
    private String itemName;
    private String athleteName;

    public Score() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getItemId() { return itemId; }
    public void setItemId(Integer itemId) { this.itemId = itemId; }
    public Integer getAthleteId() { return athleteId; }
    public void setAthleteId(Integer athleteId) { this.athleteId = athleteId; }
    public Double getValue() { return value; }
    public void setValue(Double value) { this.value = value; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public Integer getIsFoul() { return isFoul; }
    public void setIsFoul(Integer isFoul) { this.isFoul = isFoul; }
    public Integer getIsFinished() { return isFinished; }
    public void setIsFinished(Integer isFinished) { this.isFinished = isFinished; }
    public Integer getIsRecord() { return isRecord; }
    public void setIsRecord(Integer isRecord) { this.isRecord = isRecord; }
    public Integer getRank() { return rank; }
    public void setRank(Integer rank) { this.rank = rank; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }
    public String getAthleteName() { return athleteName; }
    public void setAthleteName(String athleteName) { this.athleteName = athleteName; }
}
