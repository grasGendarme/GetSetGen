GetSetGenerator is a simple OS X app to let you convert stuff like

    int count
    String name // A very useful name

to convenient java declarations, setters, getters and constructor like this:

    private int m_count;
    private String m_name;		// A very useful name
    
    
    public int getCount() {
        return m_count;
    }
    public void setCount(int count) {
    m_count = count;
    }
    public String getName() {
        return m_name;
    }
    public void setName(String name) {
        m_name = name;
    }
    public Constructor(String name) {
        this.m_count = count;
        this.m_name = name;
    }
