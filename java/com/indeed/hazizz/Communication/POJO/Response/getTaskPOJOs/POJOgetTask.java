package com.indeed.hazizz.Communication.POJO.Response.getTaskPOJOs;

import lombok.Data;

@Data
public class POJOgetTask {

    private int id;
    private String type;
    private String title;
    private String description;
    private POJOsubjectData subjectData;
    private String dueDate;
    private POJOcreator creator;
    private POJOgroupData groupData;

    public POJOgetTask(int id, String type, String title, String description, POJOsubjectData subjectData,
    String dueDate, POJOcreator creator, POJOgroupData groupData){
        this.id = id;
        this.type = type;
        this.title = title;
        this.description = description;
        this.subjectData = subjectData;
        this.dueDate = dueDate;
        this.creator = creator;
        this.groupData = groupData;
    }
}