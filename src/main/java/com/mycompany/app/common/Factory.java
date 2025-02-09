package com.mycompany.app.common;

public interface Factory<S, T> {

    T produce(S input);

}
