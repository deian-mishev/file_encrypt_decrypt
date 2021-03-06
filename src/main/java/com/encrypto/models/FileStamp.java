package com.encrypto.models;

import java.time.Duration;
import java.util.Date;

import javax.validation.constraints.Past;
import javax.validation.constraints.Size;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.DurationDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.DurationSerializer;

import lombok.Data;
import lombok.NonNull;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@RequiredArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
public class FileStamp {

    @JsonProperty("id")
    private String id;

    @JsonProperty("name")
    @Size(min = 1)
    private String name;

    @NonNull
    @JsonProperty("password")
    @Size(min = 1)
    private String password;

    @JsonProperty("iv")
    @Size(min = 1)
    private String iv;

    @JsonProperty("salt")
    @Size(min = 1)
    private String salt;

    @NonNull
    @JsonProperty("expiration")
    @JsonSerialize(using = DurationSerializer.class)
    @JsonDeserialize(using = DurationDeserializer.class)
    private Duration expiration;

    @Past
    @JsonProperty("atTime")
    private Date atTime;
}