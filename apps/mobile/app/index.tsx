import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { GOALS, GOAL_DESCRIPTIONS, GOAL_LABELS } from '@l3velup/shared';

export default function HomeScreen() {
  return (
    <ScrollView style={styles.scroll} contentContainerStyle={styles.container}>
      <Text style={styles.title}>L3velUp</Text>
      <Text style={styles.subtitle}>Choose your training goal</Text>
      <View style={styles.grid}>
        {GOALS.map((goal) => (
          <View key={goal} style={styles.card}>
            <Text style={styles.cardTitle}>{GOAL_LABELS[goal]}</Text>
            <Text style={styles.cardDesc}>{GOAL_DESCRIPTIONS[goal]}</Text>
          </View>
        ))}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  scroll: {
    flex: 1,
    backgroundColor: '#f8fafc',
  },
  container: {
    padding: 24,
    paddingBottom: 48,
  },
  title: {
    fontSize: 36,
    fontWeight: '800',
    color: '#0f172a',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 16,
    color: '#64748b',
    marginBottom: 24,
  },
  grid: {
    gap: 12,
  },
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    borderWidth: 1,
    borderColor: '#e2e8f0',
  },
  cardTitle: {
    fontSize: 15,
    fontWeight: '600',
    color: '#0f172a',
    marginBottom: 4,
  },
  cardDesc: {
    fontSize: 13,
    color: '#64748b',
    lineHeight: 18,
  },
});
