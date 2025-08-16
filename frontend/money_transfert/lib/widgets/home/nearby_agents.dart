import 'package:flutter/material.dart';

class AgentItem {
  final int id;
  final String name;
  final String distance;
  final double rating;
  final bool available;

  AgentItem({
    required this.id,
    required this.name,
    required this.distance,
    required this.rating,
    required this.available,
  });
}

class NearbyAgentsCard extends StatelessWidget {
  final List<AgentItem> agents;
  final VoidCallback onViewAll;

  const NearbyAgentsCard({
    Key? key,
    required this.agents,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Agents à proximité',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                'Voir tous',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 4,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: agents
                  .take(2)
                  .map((agent) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AgentListItem(agent: agent),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class AgentListItem extends StatelessWidget {
  final AgentItem agent;

  const AgentListItem({
    Key? key,
    required this.agent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.location_on,
            color: Colors.purple.shade600,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agent.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Text(
                    agent.distance,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    agent.rating.toString(),
                    style: TextStyle(
                      color: Colors.amber.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: agent.available
                ? Colors.green.shade100
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            agent.available ? 'Ouvert' : 'Fermé',
            style: TextStyle(
              color: agent.available
                  ? Colors.green.shade800
                  : Colors.grey.shade800,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
