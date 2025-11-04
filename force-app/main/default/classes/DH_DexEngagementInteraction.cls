public class DH_DexEngagementInteraction implements Comparable{
    public String uniqueID { get; set; }
    public String subject { get; set; }
    public Datetime timeStamp { get; set; }
    public String displayTime { get; set; }
    public String displayDate { get; set; }    
    public String description { get; set; }
    public String iconVariant { get; set; }
    
    public Integer compareTo(Object compareTo) {
        DH_DexEngagementInteraction compareToEmp = (DH_DexEngagementInteraction)compareTo;
        if(this.timeStamp < compareToEmp.timeStamp){
            return 1;
        }
        if(this.timeStamp > compareToEmp.timeStamp){
            return -1;
        }
        return 0;        
    }
}