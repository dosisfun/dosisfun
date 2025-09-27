import React, { useState, useEffect, useRef } from 'react';
import { View, Text, Image, StatusBar, TouchableOpacity, Animated, Dimensions } from 'react-native';
import { useFonts, PixelifySans_400Regular } from '@expo-google-fonts/pixelify-sans';
import { router, useLocalSearchParams } from 'expo-router';

const { width, height } = Dimensions.get('window');

export default function IntroComplete() {
  const { characterId } = useLocalSearchParams();
  const [googleFontsLoaded] = useFonts({
    PixelifySans_400Regular,
  });

  // Get character image based on selected character
  const getCharacterImage = () => {
    switch (characterId) {
      case '1':
        return require('../../assets/images/p1.png'); // Peter
      case '4':
        return require('../../assets/images/p4.png'); // Mariah
      case '20':
        return require('../../assets/images/p20.png'); // Will
      default:
        return require('../../assets/images/p1.png'); 
    }
  };

  const [currentScreen, setCurrentScreen] = useState('intro'); // 'intro', 'part2', 'zoom', 'final'
  
  const [showDialogue, setShowDialogue] = useState(false);
  const [currentSpeaker, setCurrentSpeaker] = useState('peter');
  const [dialogueIndex, setDialogueIndex] = useState(0);
  
  const [part2DialogueIndex, setPart2DialogueIndex] = useState(0);
  const [useFlowerpot2, setUseFlowerpot2] = useState(false);
  
  const [finalDialogueIndex, setFinalDialogueIndex] = useState(0);
  
  
  const [showWeed, setShowWeed] = useState(false);
  const [weedStage, setWeedStage] = useState(0);
  const [tapCount, setTapCount] = useState(0);
  const [isGrowing, setIsGrowing] = useState(false); 

  // Animations
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const peterAnim = useRef(new Animated.Value(0)).current;
  const bossAnim = useRef(new Animated.Value(0)).current;
  const dialogueAnim = useRef(new Animated.Value(0)).current;
  const flowerpotAnim = useRef(new Animated.Value(0)).current;

  // Intro dialogues
  const introDialogues = [
    { speaker: 'peter', text: "I promise... I will pay next week." },
    { speaker: 'boss', text: "Your promises are not worth, you owe me $20k one month ago!" },
    { speaker: 'boss', text: "I'll give you one more week, if I don't see my money, I will chop off your head." },
  ];

  // Part2 dialogues
  const part2Dialogues = [
    { text: "That was close, I must do something to get that money..." },
    { text: "I can plant some weed and sell it..." },
  ];

  // Final screen dialogues
  const finalDialogues = [
    { text: "I need to sell this somewhere" },
  ];

  useEffect(() => {
    if (currentScreen === 'intro') {
      // Intro screen animations
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 2000,
        useNativeDriver: true,
      }).start();

      setTimeout(() => {
        Animated.timing(peterAnim, {
          toValue: 1,
          duration: 1500,
          useNativeDriver: true,
        }).start();
      }, 1000);

      setTimeout(() => {
        Animated.timing(bossAnim, {
          toValue: 1,
          duration: 1500,
          useNativeDriver: true,
        }).start();
      }, 2000);

      setTimeout(() => {
        setShowDialogue(true);
        setCurrentSpeaker(introDialogues[0].speaker);
        Animated.timing(dialogueAnim, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        }).start();
      }, 3500);
    } else if (currentScreen === 'part2') {
      // Part2 screen animations
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 2000,
        useNativeDriver: true,
      }).start();

      setTimeout(() => {
        Animated.timing(peterAnim, {
          toValue: 1,
          duration: 1500,
          useNativeDriver: true,
        }).start();
      }, 1000);

      setTimeout(() => {
        setShowDialogue(true);
        Animated.timing(dialogueAnim, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        }).start();
      }, 2500);
    } else if (currentScreen === 'zoom') {
      // Zoom screen animations
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 2000,
        useNativeDriver: true,
      }).start();

      setTimeout(() => {
        Animated.timing(flowerpotAnim, {
          toValue: 1,
          duration: 1500,
          useNativeDriver: true,
        }).start();
      }, 1000);
    } else if (currentScreen === 'final') {
      // Final screen animations
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 2000,
        useNativeDriver: true,
      }).start();

      setTimeout(() => {
        Animated.timing(peterAnim, {
          toValue: 1,
          duration: 1500,
          useNativeDriver: true,
        }).start();
      }, 1000);

      setTimeout(() => {
        setShowDialogue(true);
        Animated.timing(dialogueAnim, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        }).start();
      }, 2500);
    }
  }, [currentScreen]);

  const nextDialogue = () => {
    if (currentScreen === 'intro') {
      if (dialogueIndex < introDialogues.length - 1) {
        const newIndex = dialogueIndex + 1;
        const newSpeaker = introDialogues[newIndex].speaker;
        
        setDialogueIndex(newIndex);
        setCurrentSpeaker(newSpeaker);
        
        dialogueAnim.setValue(0);
        Animated.timing(dialogueAnim, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        }).start();
      } else {
        setCurrentScreen('part2');
        setShowDialogue(false);
        setDialogueIndex(0);
        setPart2DialogueIndex(0);
        setUseFlowerpot2(false);
        // Reset animations
        fadeAnim.setValue(0);
        peterAnim.setValue(0);
        dialogueAnim.setValue(0);
      }
    } else if (currentScreen === 'part2') {
      if (part2DialogueIndex < part2Dialogues.length - 1) {
        const newIndex = part2DialogueIndex + 1;
        setPart2DialogueIndex(newIndex);
        
        if (newIndex >= 1) {
          setUseFlowerpot2(true);
        }
        
        dialogueAnim.setValue(0);
        Animated.timing(dialogueAnim, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        }).start();
      } else {
        setCurrentScreen('zoom');
        setShowDialogue(false);
        setPart2DialogueIndex(0);
        setUseFlowerpot2(false);
        setShowWeed(false);
        setWeedStage(0);
        fadeAnim.setValue(0);
        peterAnim.setValue(0);
        dialogueAnim.setValue(0);
        flowerpotAnim.setValue(0);
      }
    } else if (currentScreen === 'final') {
      if (finalDialogueIndex < finalDialogues.length - 1) {
        const newIndex = finalDialogueIndex + 1;
        setFinalDialogueIndex(newIndex);
        
        dialogueAnim.setValue(0);
        Animated.timing(dialogueAnim, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        }).start();
      } else {
        router.replace('/wallet');
      }
    }
  };

  const getRequiredTaps = (stage: number) => {
    switch (stage) {
      case 1: return 100; // weed1 → weed2
      case 2: return 200; // weed2 → weed3
      case 3: return 300; // weed3 → weed4
      case 4: return 500; // weed4 → final
      default: return 100;
    }
  };

  const handleZoomTap = () => {
    if (weedStage === 0) {
      // First tap: show weed level 1
      setShowWeed(true);
      setWeedStage(1);
    } else if (weedStage >= 1 && weedStage <= 4) {
      // Increment tap count for growing
      const newTapCount = tapCount + 1;
      setTapCount(newTapCount);
      
      const requiredTaps = getRequiredTaps(weedStage);
      
      // Check if we've reached required taps for current stage
      if (newTapCount >= requiredTaps) {
        if (weedStage < 4) {
          // Grow to next stage
          setWeedStage(weedStage + 1);
          setTapCount(0); // Reset tap count for next stage
        } else {
          // Final stage reached, navigate to final screen
          setCurrentScreen('final');
          setShowWeed(false);
          setWeedStage(0);
          setTapCount(0);
          setFinalDialogueIndex(0);
          setShowDialogue(false);
          fadeAnim.setValue(0);
          peterAnim.setValue(0);
          dialogueAnim.setValue(0);
          flowerpotAnim.setValue(0);
        }
      }
    }
  };

  const handleTap = () => {
    if (currentScreen === 'zoom') {
      handleZoomTap();
    } else {
      nextDialogue();
    }
  };

  const renderFinalScreen = () => (
    <>
      <Animated.Image
        source={require('../../assets/images/housebackground.png')}
        style={{
          position: 'absolute',
          width: '100%',
          height: '100%',
          opacity: fadeAnim,
        }}
        resizeMode="cover"
      />

      <Animated.View style={{
        position: 'absolute',
        left: width * 0.02,
        bottom: 0,
        opacity: peterAnim,
        transform: [{
          translateY: peterAnim.interpolate({
            inputRange: [0, 1],
            outputRange: [50, 0],
          })
        }]
      }}>
        <Image
          source={getCharacterImage()}
          style={{
            width: width * 0.55,
            height: height * 0.65,
          }}
          resizeMode="contain"
        />
      </Animated.View>

      <Animated.View style={{
        position: 'absolute',
        right: width * 0.1,
        bottom: height * 0.08,
        opacity: fadeAnim,
      }}>
        <Image
          source={require('../../assets/images/weed5.png')}
          style={{
            width: width * 0.4,
            height: height * 0.5,
          }}
          resizeMode="contain"
        />
      </Animated.View>

      {showDialogue && (
        <Animated.View style={{
          position: 'absolute',
          left: width * 0.15,
          top: height * 0.2,
          opacity: dialogueAnim,
          transform: [{
            scale: dialogueAnim.interpolate({
              inputRange: [0, 1],
              outputRange: [0.8, 1],
            })
          }]
        }}>
          <View style={{
            backgroundColor: '#FFFFFF',
            paddingHorizontal: 20,
            paddingVertical: 15,
            borderRadius: 0,
            borderWidth: 3,
            borderColor: '#000000',
            maxWidth: width * 0.7,
            shadowColor: '#000000',
            shadowOffset: { width: 2, height: 2 },
            shadowOpacity: 0.3,
            shadowRadius: 0,
            elevation: 4,
          }}>
            <Text style={{
              fontSize: 16,
              color: '#000000',
              fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
              textAlign: 'left',
              lineHeight: 20,
              fontWeight: 'bold',
            }}>
              {finalDialogues[finalDialogueIndex].text}
            </Text>
          </View>
        </Animated.View>
      )}

      {showDialogue && (
        <Animated.View style={{
          position: 'absolute',
          bottom: height * 0.05,
          alignSelf: 'center',
          opacity: dialogueAnim,
        }}>
          <Text style={{
            fontSize: 14,
            color: 'rgba(255, 255, 255, 0.7)',
            fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
            textAlign: 'center',
          }}>
            TAP TO CONTINUE
          </Text>
        </Animated.View>
      )}
    </>
  );

  const renderIntroScreen = () => (
    <>
      <Animated.Image
        source={require('../../assets/images/introbackground.png')}
        style={{
          position: 'absolute',
          width: '100%',
          height: '100%',
          opacity: fadeAnim,
        }}
        resizeMode="cover"
      />

      <Animated.View style={{
        position: 'absolute',
        left: width * 0.05,
        bottom: 0,
        opacity: peterAnim,
        transform: [{
          translateX: peterAnim.interpolate({
            inputRange: [0, 1],
            outputRange: [-100, 0],
          })
        }]
      }}>
        <Image
          source={getCharacterImage()}
          style={{
            width: width * 0.4,
            height: height * 0.5,
            opacity: currentSpeaker === 'peter' ? 1 : 0.4,
          }}
          resizeMode="contain"
        />
      </Animated.View>

      <Animated.View style={{
        position: 'absolute',
        right: width * 0.05,
        bottom: 0,
        opacity: bossAnim,
        transform: [{
          translateX: bossAnim.interpolate({
            inputRange: [0, 1],
            outputRange: [100, 0],
          })
        }]
      }}>
        <Image
          source={require('../../assets/images/pboss.png')}
          style={{
            width: width * 0.45,
            height: height * 0.55,
            opacity: currentSpeaker === 'boss' ? 1 : 0.4,
          }}
          resizeMode="contain"
        />
      </Animated.View>

      {showDialogue && (
        <Animated.View style={{
          position: 'absolute',
          left: currentSpeaker === 'peter' ? width * 0.15 : width * 0.25,
          top: height * 0.25,
          opacity: dialogueAnim,
          transform: [{
            scale: dialogueAnim.interpolate({
              inputRange: [0, 1],
              outputRange: [0.8, 1],
            })
          }]
        }}>
          <View style={{
            backgroundColor: '#FFFFFF',
            paddingHorizontal: 20,
            paddingVertical: 15,
            borderRadius: 0,
            borderWidth: 3,
            borderColor: '#000000',
            maxWidth: width * 0.6,
            shadowColor: '#000000',
            shadowOffset: { width: 2, height: 2 },
            shadowOpacity: 0.3,
            shadowRadius: 0,
            elevation: 4,
          }}>
            <Text style={{
              fontSize: 16,
              color: '#000000',
              fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
              textAlign: 'center',
              lineHeight: 20,
              fontWeight: 'bold',
            }}>
              {introDialogues[dialogueIndex].text}
            </Text>
          </View>
        </Animated.View>
      )}

      {showDialogue && (
        <Animated.View style={{
          position: 'absolute',
          bottom: height * 0.05,
          alignSelf: 'center',
          opacity: dialogueAnim,
        }}>
          <Text style={{
            fontSize: 14,
            color: 'rgba(255, 255, 255, 0.7)',
            fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
            textAlign: 'center',
          }}>
            TAP TO CONTINUE
          </Text>
        </Animated.View>
      )}
    </>
  );

  const renderPart2Screen = () => (
    <>
      <Animated.Image
        source={require('../../assets/images/housebackground.png')}
        style={{
          position: 'absolute',
          width: '100%',
          height: '100%',
          opacity: fadeAnim,
        }}
        resizeMode="cover"
      />

      <Animated.View style={{
        position: 'absolute',
        left: width * 0.02,
        bottom: 0,
        opacity: peterAnim,
        transform: [{
          translateY: peterAnim.interpolate({
            inputRange: [0, 1],
            outputRange: [50, 0],
          })
        }]
      }}>
        <Image
          source={getCharacterImage()}
          style={{
            width: width * 0.55,
            height: height * 0.65,
          }}
          resizeMode="contain"
        />
      </Animated.View>

      <Animated.View style={{
        position: 'absolute',
        right: width * 0.23,
        bottom: height * 0.08,
        opacity: fadeAnim,
      }}>
        <Image
          source={useFlowerpot2 ? require('../../assets/images/flowerpot2.png') : require('../../assets/images/flowerpot.png')}
          style={{
            width: width * 0.2,
            height: height * 0.25,
          }}
          resizeMode="contain"
        />
      </Animated.View>

      {showDialogue && (
        <Animated.View style={{
          position: 'absolute',
          left: width * 0.15,
          top: height * 0.2,
          opacity: dialogueAnim,
          transform: [{
            scale: dialogueAnim.interpolate({
              inputRange: [0, 1],
              outputRange: [0.8, 1],
            })
          }]
        }}>
          <View style={{
            backgroundColor: '#FFFFFF',
            paddingHorizontal: 20,
            paddingVertical: 15,
            borderRadius: 0,
            borderWidth: 3,
            borderColor: '#000000',
            maxWidth: width * 0.7,
            shadowColor: '#000000',
            shadowOffset: { width: 2, height: 2 },
            shadowOpacity: 0.3,
            shadowRadius: 0,
            elevation: 4,
          }}>
            <Text style={{
              fontSize: 16,
              color: '#000000',
              fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
              textAlign: 'left',
              lineHeight: 20,
              fontWeight: 'bold',
            }}>
              {part2Dialogues[part2DialogueIndex].text}
            </Text>
          </View>
        </Animated.View>
      )}

      {showDialogue && (
        <Animated.View style={{
          position: 'absolute',
          bottom: height * 0.05,
          alignSelf: 'center',
          opacity: dialogueAnim,
        }}>
          <Text style={{
            fontSize: 14,
            color: 'rgba(255, 255, 255, 0.7)',
            fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
            textAlign: 'center',
          }}>
            TAP TO CONTINUE
          </Text>
        </Animated.View>
      )}
    </>
  );

  const renderZoomScreen = () => (
    <>
      <Animated.Image
        source={require('../../assets/images/housebackground zoom.png')}
        style={{
          position: 'absolute',
          width: '100%',
          height: '100%',
          opacity: fadeAnim,
        }}
        resizeMode="cover"
      />

      <Animated.View style={{
        position: 'absolute',
        left: weedStage === 4 ? width * 0.5 - (width * 1.0) / 2 : width * 0.5 - (width * 0.6) / 2,
        bottom: weedStage > 0 ? -height * 0.02 : -height * 0.25,
        opacity: flowerpotAnim,
        transform: [{
          translateY: flowerpotAnim.interpolate({
            inputRange: [0, 1],
            outputRange: [50, 0],
          })
        }]
      }}>
        <Image
          source={
            weedStage === 0 
              ? require('../../assets/images/flowerpot2.png')
              : weedStage === 1 
                ? require('../../assets/images/weed1.png')
                : weedStage === 2
                  ? require('../../assets/images/weed2.png')
                  : weedStage === 3
                    ? require('../../assets/images/weed3.png')
                    : require('../../assets/images/weed4.png')
          }
          style={{
            width: weedStage === 4 ? width * 1.0 : width * 0.6,
            height: weedStage === 4 ? height * 1.2 : height * 0.7,
          }}
          resizeMode="contain"
        />
      </Animated.View>

      <Animated.View style={{
        position: 'absolute',
        bottom: height * 0.05,
        alignSelf: 'center',
        opacity: flowerpotAnim,
      }}>
        <Text style={{
          fontSize: 16,
          color: '#FFFFFF',
          fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
          textAlign: 'center',
          fontWeight: 'bold',
        }}>
          {weedStage === 0 ? 'tap... tap ... tap' : `Taps: ${tapCount}/${getRequiredTaps(weedStage)}`}
        </Text>
      </Animated.View>
    </>
  );

  return (
    <TouchableOpacity 
      style={{ flex: 1, backgroundColor: '#000000' }}
      onPress={handleTap}
      activeOpacity={1}
    >
      <StatusBar hidden />
      
      {currentScreen === 'intro' && renderIntroScreen()}
      {currentScreen === 'part2' && renderPart2Screen()}
      {currentScreen === 'zoom' && renderZoomScreen()}
      {currentScreen === 'final' && renderFinalScreen()}
    </TouchableOpacity>
  );
}
