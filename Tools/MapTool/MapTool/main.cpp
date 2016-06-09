#include <array>
#include <fstream>
#include <sstream>
#include <iostream>
#include <limits>
#include <set>
#include <vector>

namespace
{
	bool AlmostZero(float value)
	{
		const float epsilon = std::numeric_limits<float>::epsilon();

		return ((value < epsilon) && (value > -epsilon));
	}

	bool AlmostEqual(float v1, float v2)
	{
		return AlmostZero(v1 - v2);
	}

	struct Vertex
	{	
		float x;
		float y;
		float z;

		Vertex():
			x(0.0f),
			y(0.0f),
			z(0.0f)
		{
		}

		Vertex(float x, float y, float z):
			x(x),
			y(y),
			z(z)
		{
		}

		bool operator==(const Vertex& rhs) const
		{
			return AlmostEqual(x, rhs.x) &&
				AlmostEqual(y, rhs.y) &&
				AlmostEqual(z, rhs.z);
		}
	};

	struct Edge
	{
		Vertex v1;
		Vertex v2;

		Edge(const Vertex& v1, const Vertex& v2):
			v1(v1),
			v2(v2)
		{
		}

		bool operator==(const Edge& rhs) const
		{
			return ((v1 == rhs.v1) && (v2 == rhs.v2)) ||
				((v1 == rhs.v2) && (v2 == rhs.v1));
		}
	};

	struct Bounds
	{
		Bounds():
			min_x(std::numeric_limits<float>::max()),
			min_z(std::numeric_limits<float>::max()),
			max_x(std::numeric_limits<float>::lowest()),
			max_z(std::numeric_limits<float>::lowest())
		{
		}

		float min_x;
		float min_z;
		float max_x;
		float max_z;
	};

	using Edges = std::vector<Edge>;
	using Triangle = std::array<Vertex, 3>;
	using Indices = std::set<int>;

	bool IsVertical(const Triangle& triangle)
	{
		if ((triangle[0].y == triangle[1].y) &&
			(triangle[1].y == triangle[2].y))
		{
			return false;
		}

		// The triangle is vertical if its area (as seen from above) is zero.
		return AlmostZero((triangle[0].x * (triangle[1].z - triangle[2].z)) +
						  (triangle[1].x * (triangle[2].z - triangle[0].z)) +
						  (triangle[2].x * (triangle[0].z - triangle[1].z)));
	}

	float GetDistance(Vertex& v1, Vertex& v2)
	{
		float diff_x = (v1.x - v2.x);
		float diff_y = (v1.y - v2.y);
		float diff_z = (v1.z - v2.z);

		return std::sqrt((diff_x * diff_x) + (diff_y * diff_y) + (diff_z * diff_z));
	}

	bool IsOnEdge(Vertex& vertex, Edge& edge)
	{
		float distance1 = (GetDistance(edge.v1, vertex) + GetDistance(vertex, edge.v2));
		float distance2 = GetDistance(edge.v1, edge.v2);

		return AlmostEqual(distance1, distance2);
	}
}

int main(int argc, const char* argv[])
{
	if(argc < 5)
	{
		std::cout << "Missing arguments." << std::endl;

		return 0;
	}

	const std::string input_filename(argv[1]);
	const std::string output_filename(argv[argc - 1]);

	std::ifstream inputFile(input_filename);
	std::ofstream outputFile(output_filename);

	if(!inputFile.is_open() || !outputFile.is_open())
	{
		std::cout << "Couldn't open file." << std::endl;

		return 0;
	}

	Bounds bounds;
	Edges edges;
	Triangle triangle;

	std::string line;

	int vertexIndex = 0;	

	while(std::getline(inputFile, line))
	{
		std::stringstream stringstream;

		stringstream << line;

		std::string prefix;

		stringstream >> prefix;

		if(prefix != "v")
		{
			continue;
		}

		float x, y, z;

		stringstream >> x >> y >> z;

		triangle[vertexIndex++] = Vertex(x, y, z);

		if(vertexIndex < 3)
		{
			continue;
		}
		
		vertexIndex = 0;

		// Ignore vertical triangles
		if(IsVertical(triangle))
		{
			continue;
		}

		// Update bounds
		for (auto& vertex : triangle)
		{
			bounds.min_x = std::min(bounds.min_x, vertex.x);
			bounds.min_z = std::min(bounds.min_z, vertex.z);
			bounds.max_x = std::max(bounds.max_x, vertex.x);
			bounds.max_z = std::max(bounds.max_z, vertex.z);
		}

		// Add the three edges of the triangle to our list
		for(int i = 0; i < (int)triangle.size(); i++)
		{
			int j = ((i + 1) % triangle.size());

			edges.emplace_back(triangle[i], triangle[j]);
		}
	}

	Indices indicesToRemove;
	
	// Loop through all pairs of edges and remove any overlapping parts.
	for (int i = 0; i < (int)edges.size(); i++)
	{
		if (indicesToRemove.find(i) != indicesToRemove.cend())
		{
			continue;
		}		

		for (int j = 0; j < (int)edges.size(); j++)
		{
			if (i == j)
			{
				continue;
			}

			if (indicesToRemove.find(j) != indicesToRemove.cend())
			{
				continue;
			}
			
			auto& edge1 = edges[i];
			auto& edge2 = edges[j];

			// Is the second edge within the first?
			// e1.v1-----e2.v1-----e2.v2-----e1.v2?
			if (IsOnEdge(edge2.v1, edge1) && IsOnEdge(edge2.v2, edge1))
			{
				const bool isReversed = (GetDistance(edge1.v1, edge2.v2) <= GetDistance(edge1.v1, edge2.v1));

				auto& vertex1 = (isReversed ? edge1.v2 : edge1.v1);
				auto& vertex2 = (isReversed ? edge1.v1 : edge1.v2);
				
				// Does the first edge share an endpoint with the second?
				// e1.v1/e2.v1-----e2.v2-----e1.v2
				if ((vertex1 == edge2.v1) || (vertex2 == edge2.v2))
				{
					// Is the first endpoint shared?
					// e1.v1/e2.v1-----e2.v2-----e1.v2
					if (vertex1 == edge2.v1)
					{
						// Is the second edge equal to the first?
						// e1.v1/e2.v2----------e1.v2/e2.v2?
						if (vertex2 == edge2.v2)
						{
							indicesToRemove.insert(i);
							indicesToRemove.insert(j);

							break;
						}

						vertex1 = edge2.v2;
					}
					// The second endpoint is shared
					// e1.v1-----e2.v1-----e1.v2/e2.v2
					else
					{
						vertex2 = edge2.v1;
					}
					
					indicesToRemove.insert(j);
				}
				// The second edge is fully within the first.
				// e1.v1-----e2.v1-----e2.v2-----e1.v2
				else
				{
					// Swap two of the points to create new edges around the gap
					// e1.v1-----e1.v2     e2.v2-----e2.v1
					std::swap(vertex2, edge2.v1);

					edges.push_back(edge2);

					indicesToRemove.insert(j);
				}				
			}
		}
	}

	// Remove the shared edges
	for (auto it = indicesToRemove.crbegin(); it != indicesToRemove.crend(); it++)
	{
		edges.erase(edges.cbegin() + (*it));
	}

	outputFile << "[Scale]" << std::endl;
	outputFile << argv[2] << std::endl;
	outputFile << "[Bounds]" << std::endl;
	outputFile << bounds.min_x << " " << bounds.min_z << " " << bounds.max_x << " " << bounds.max_z << std::endl;
	outputFile << "[Floors]" << std::endl;

	for (int i = 3; i < (argc - 1); i++)
	{
		outputFile << argv[i] << " ";
	}

	outputFile << std::endl;
	outputFile << "[Edges]" << std::endl;

	for (const auto& edge : edges)
	{
		const Vertex& v1 = edge.v1;
		const Vertex& v2 = edge.v2;

		outputFile << v1.x << " " << v1.y << " "  << v1.z << " " << v2.x << " " << v2.y << " " << v2.z << std::endl;
	}
}