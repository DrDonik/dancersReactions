%% Initialization

% these are the properties of the registration system
eventProps = {'number of places',...
    'registering schedule',...
    'roled',...
    'partnered preferred',...
    'price-pattern',...
};

totalLeadersRejected = 0;
totalFollowersRejected = 0;

% make an initial population of dancers
leadFollowRatio = 0.8;
initialDancerPopulation = 250;
initialLeaderPopulation = round(initialDancerPopulation/2*leadFollowRatio);
initialFollowerPopulation = round(initialDancerPopulation/2/leadFollowRatio);

leaders = createNewDancers(initialLeaderPopulation);
followers = createNewDancers(initialFollowerPopulation);

% what part of the dancers is partnered?
partneredRatio = 0.5;
partneredDancers = partneredRatio*min(initialLeaderPopulation,initialLeaderPopulation);
leaders(partneredDancers+1:end, 13)=0; % now the initial population is partially partnered
followers(partneredDancers+1:end, 13)=0;

dancerSummaryFigure = figure;

for i = 1:100
    %% New dancers will join the scene regularly
    newLeaderPopulation = 5;
    newFollowerPopulation = round(newLeaderPopulation/leadFollowRatio);
    leaders = [leaders; createNewDancers(newLeaderPopulation)];
    followers = [followers; createNewDancers(newFollowerPopulation)];
    
    %% Dancers with negative happiness are no longer part of the scene
    leadersDancingIndeces = leaders(:, 11) > 0;
    currentLeaderPopulation = sum(leadersDancingIndeces);
    followersDancingIndeces = followers(:, 11) > 0;
    currentFollowerPopulation = sum(followersDancingIndeces);
    
    %% Display the dancers mean happiness values
    errorbar(i, mean(leaders(leadersDancingIndeces,11)), std(leaders(leadersDancingIndeces,11)), 'ro')
    hold on
    errorbar(i, mean(followers(followersDancingIndeces,11)), std(followers(followersDancingIndeces,11)), 'bo')

    %% Start an event registration and check who is getting in
    % set the properties of an event
    thisEventProps = [100,1,1,1,1];

    % not all will want to participate (currently about half)
    applicantsLeadersIndices = logical(randi(2,1,length(leaders))' - 1);
    applicantsLeadersIndices = find(applicantsLeadersIndices & leadersDancingIndeces);
    thisEventLeadersIndices = leaders(applicantsLeadersIndices, :);
    applicantsFollowersIndices = logical(randi(2,1,length(followers))' - 1);
    applicantsFollowersIndices = find(applicantsFollowersIndices & followersDancingIndeces);
    thisEventFollowersIndices = followers(applicantsFollowersIndices, :);

    % sort the population by their planned-attributed, modified by their motivation
    % the more planned and the more happy/motivated they are, the earlier will
    % the register
    [~, sortedApplicantsLeadersIndices] = sort(thisEventLeadersIndices(:, 1) + thisEventLeadersIndices(:, 11), 1, 'descend');
    thisEventLeadersIndices = applicantsLeadersIndices(sortedApplicantsLeadersIndices);
    [~, sortedApplicantsFollowersIndices] = sort(thisEventFollowersIndices(:, 1) + thisEventFollowersIndices(:, 11), 1, 'descend');
    thisEventFollowersIndices = applicantsFollowersIndices(sortedApplicantsFollowersIndices);

    switch thisEventProps(3)
        case 0
            % this is an un-roled event

        case 1
            % this is a roled event

            % find who made it into the workshop
            thisEventLeadersIndices = thisEventLeadersIndices(1:min(length(thisEventLeadersIndices),thisEventProps(1)/2));
            thisEventFollowersIndices = thisEventFollowersIndices(1:min(length(thisEventFollowersIndices),length(thisEventLeadersIndices)),:);
            thisEventLeadersIndices = thisEventLeadersIndices(1:min(length(thisEventLeadersIndices),length(thisEventFollowersIndices)));

        case 2
            % this is a partnered event
    end

    % keep a total of how many got rejected at all events
    totalLeadersRejected = totalLeadersRejected + length(applicantsLeadersIndices) - length(thisEventLeadersIndices);
    totalFollowersRejected = totalFollowersRejected + length(applicantsFollowersIndices) - length(thisEventFollowersIndices);

    % mark the participation for each dancer
    leaders(thisEventLeadersIndices, 13) = leaders(thisEventLeadersIndices, 13) + 1;
    followers(thisEventFollowersIndices, 13) = followers(thisEventFollowersIndices, 13) + 1;

    % the happiness/motivation of everybody goes down with time
    leaders(:, 11) = leaders(:, 11) - 0.05;
    followers(:, 11) = followers(:, 11) - 0.05;

    % update the happiness/motivation of the rejected, depending on their frustration tolerance
    % (it seems as if we degraded all; but we will update the actual participants in the next step)
    leaders(applicantsLeadersIndices, 11) = leaders(applicantsLeadersIndices, 11) - 1./leaders(applicantsLeadersIndices, 10);
    followers(applicantsFollowersIndices, 11) = followers(applicantsFollowersIndices, 11) - 1./followers(applicantsFollowersIndices, 10);

    % update the happiness/motivation of the participants
    leaders(thisEventLeadersIndices, 11) = leaders(thisEventLeadersIndices, 11) + 1;
    followers(thisEventFollowersIndices, 11) = followers(thisEventFollowersIndices, 11) + 1;

end

function newDancers = createNewDancers(numberOfNewDancers)
% these are the different properties that make up the dancers stance on
% different topics. 0 is "medium", negative means no, positive means yes
dancerProps = {'planned',...
    'price-sensitive',...
    'roled',...
    'partnered',...
    'outgoing',...
    'equalitarian',...
    'feminist/masculinist',...
    'home-scene bound',...
    'returning',...
    'frustration-tolerant',...
    'happy/motivated',...
    'preferred partner',...
    'visited workshops'...
};

newDancers = [randn(numberOfNewDancers, length(dancerProps) - 4), ... % the personal attributes are normally distributed
    abs(randn(numberOfNewDancers, 1)*0.1 + 1), ... % the frustration tolerance is a multiplicator and can only be positive
    randn(numberOfNewDancers, 1) + 10, ... % everybody starts out quite happy
    zeros(numberOfNewDancers, 1), ... % at initialisation, nobody is partnered.
    zeros(numberOfNewDancers, 1)]; % nobody has participated at an event yet.

return
end