/**
 * Character Context
 * Manages the selected character state throughout the application
 */

import React, { createContext, useContext, useState, ReactNode } from 'react';
import { NFTData } from '../types/nft';

interface CharacterContextType {
  selectedCharacter: NFTData | null;
  setSelectedCharacter: (character: NFTData | null) => void;
  clearCharacter: () => void;
}

const CharacterContext = createContext<CharacterContextType | undefined>(undefined);

interface CharacterProviderProps {
  children: ReactNode;
}

/**
 * Character Context Provider
 * Wraps the app to provide character selection state
 */
export function CharacterProvider({ children }: CharacterProviderProps) {
  const [selectedCharacter, setSelectedCharacter] = useState<NFTData | null>(null);

  const clearCharacter = () => {
    setSelectedCharacter(null);
  };

  return (
    <CharacterContext.Provider
      value={{
        selectedCharacter,
        setSelectedCharacter,
        clearCharacter,
      }}
    >
      {children}
    </CharacterContext.Provider>
  );
}

/**
 * Hook to access character context
 * @throws Error if used outside CharacterProvider
 */
export function useCharacter() {
  const context = useContext(CharacterContext);
  if (context === undefined) {
    throw new Error('useCharacter must be used within a CharacterProvider');
  }
  return context;
}
