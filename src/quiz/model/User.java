package quiz.model;

public class User {
    private int userId;
    private String username;
    private String password;
    private boolean isTeacher;
    
    public User() {
    }
    
    public User(int userId, String username, String password, boolean isTeacher) {
        this.userId = userId;
        this.username = username;
        this.password = password;
        this.isTeacher = isTeacher;
    }
    
    // Getters and Setters
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public boolean isTeacher() {
        return isTeacher;
    }
    
    public void setTeacher(boolean isTeacher) {
        this.isTeacher = isTeacher;
    }
    
    @Override
    public String toString() {
        return "User{" +
                "userId=" + userId +
                ", username='" + username + '\'' +
                ", isTeacher=" + isTeacher +
                '}';
    }
}