#ifndef CORSIX_TH_TH_SINGLETON_H_
#define CORSIX_TH_TH_SINGLETON_H_

// Inspired by Commander Genius GsSingleton, full credits to Commander Genius
template <class T>
class THSingleton
{
public:
    static T& get();

    THSingleton() {}

private:
    THSingleton( const THSingleton& );
};

template <class T>
T& THSingleton<T>::get()
{
    static T instance;
    return instance;
}

#endif // CORSIX_TH_TH_SINGLETON_H_