declare module 'react-native' {
  import { Component } from 'react';
  
  export interface ViewProps {
    style?: any;
    children?: React.ReactNode;
    [key: string]: any;
  }
  
  export interface TextProps {
    style?: any;
    children?: React.ReactNode;
    [key: string]: any;
  }
  
  export interface ImageProps {
    source?: any;
    style?: any;
    resizeMode?: string;
    onError?: (error: any) => void;
    [key: string]: any;
  }
  
  export interface ScrollViewProps {
    contentContainerStyle?: any;
    showsVerticalScrollIndicator?: boolean;
    children?: React.ReactNode;
    [key: string]: any;
  }
  
  export interface TouchableOpacityProps {
    onPress?: () => void;
    style?: any;
    disabled?: boolean;
    children?: React.ReactNode;
    [key: string]: any;
  }
  
  export interface StatusBarProps {
    hidden?: boolean;
    [key: string]: any;
  }
  
  export const View: React.ComponentType<ViewProps>;
  export const Text: React.ComponentType<TextProps>;
  export const Image: React.ComponentType<ImageProps>;
  export const ScrollView: React.ComponentType<ScrollViewProps>;
  export const TouchableOpacity: React.ComponentType<TouchableOpacityProps>;
  export const StatusBar: React.ComponentType<StatusBarProps>;
  
  export namespace Animated {
    export interface AnimatedValue {
      setValue: (value: number) => void;
      addListener: (callback: (value: { value: number }) => void) => string;
      removeListener: (id: string) => void;
      removeAllListeners: () => void;
      stopAnimation: (callback?: (value: number) => void) => void;
      resetAnimation: (callback?: (value: number) => void) => void;
      interpolate: (config: any) => any;
    }
    
    export function Value(value: number): AnimatedValue;
    export function timing(value: AnimatedValue, config: any): any;
    export function sequence(animations: any[]): any;
    
    export interface AnimatedComponentProps {
      style?: any;
      children?: React.ReactNode;
      [key: string]: any;
    }
    
    export const View: React.ComponentType<AnimatedComponentProps>;
  }
}
