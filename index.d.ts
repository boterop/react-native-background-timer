import {
    EmitterSubscription,
    TurboModule,
} from 'react-native';

declare module '@boterop/react-native-background-timer' {
    export interface TimerCallback {
        callback: () => void;
        interval: boolean;
        timeout: number;
    }

    export interface RNBackgroundTimerModule extends TurboModule {
        start: (delay?: number) => void;
        stop: () => void;
        setTimeout: (id: number, timeout: number) => void;
        clearTimeout?: (id: number) => void;
    }

    export interface BackgroundTimerInterface {
        uniqueId: number;
        callbacks: Record<number, TimerCallback>;
        backgroundTimer?: number;
        backgroundListener?: EmitterSubscription;

        start: (delay?: number) => void;
        stop: () => void;

        runBackgroundTimer: (callback: () => void, delay: number) => void;
        backgroundClockMethod: (callback: () => void, delay: number) => void;
        stopBackgroundTimer: () => void;

        setTimeout: (callback: () => void, timeout: number) => number;
        clearTimeout: (timeoutId: number) => void;

        setInterval: (callback: () => void, timeout: number) => number;
        clearInterval: (intervalId: number) => void;
    }

    const BackgroundTimer: BackgroundTimerInterface;
    export default BackgroundTimer;
}
